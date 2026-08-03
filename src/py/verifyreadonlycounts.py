import os
import sys
import time
import logging
import argparse
import datetime

import arcpy
import csclelementmgr
from resourcemanager import listmanager


def setup_logging(targetgdb):

    timestr = time.strftime("%Y%m%d-%H%M%S")
    targetlogdir = os.environ.get('TARGETLOGDIR', '.')
    targetlog = os.path.join(
        targetlogdir,
        'verifyreadonlycounts-{0}-{1}.log'.format(
            os.path.basename(targetgdb).split(".")[0],
            timestr
        )
    )

    logger = logging.getLogger(__name__)
    if logger.handlers:
        return logger

    if sys.version_info >= (3, 3):
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(targetlog),
                logging.StreamHandler()
            ]
        )
        return logging.getLogger(__name__)

    logger.setLevel(logging.INFO)
    fh = logging.FileHandler(targetlog)
    sh = logging.StreamHandler()
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    fh.setFormatter(formatter)
    sh.setFormatter(formatter)
    logger.addHandler(fh)
    logger.addHandler(sh)

    return logger


def read_list(listref):

    if os.path.exists(listref):
        with open(listref) as handle:
            return [line.strip() for line in handle if line.strip()]

    return listmanager(listref).names


def candidate_itempaths(itempath, owner):

    owner = owner.upper()

    if '/' not in itempath:
        return [
            '{0}.{1}'.format(owner, itempath),
            itempath
        ]

    parts = itempath.split('/')
    qualified_parts = ['{0}.{1}'.format(owner, part) for part in parts]

    return [
        '/'.join(qualified_parts),
        '{0}.{1}'.format(owner, itempath),
        itempath
    ]


def count_with_owner(csclelement, gdb, owner, readonly_user):

    if not csclelement.istable:
        return 0

    attempts = []

    for itempath in candidate_itempaths(csclelement.itempath, owner):
        fullpath = os.path.join(gdb, itempath)
        if not arcpy.Exists(fullpath):
            attempts.append('{0} [missing]'.format(fullpath))
            continue
        try:
            return int(arcpy.management.GetCount(fullpath)[0])
        except arcpy.ExecuteError:
            errmsg = arcpy.GetMessages(2) or arcpy.GetMessages()
            errmsg = errmsg.replace('\r', ' ').replace('\n', ' | ')
            attempts.append('{0} [GetCount failed: {1}]'.format(fullpath, errmsg))
            continue
        except Exception as ex:
            attempts.append('{0} [GetCount raised: {1}]'.format(fullpath, ex))
            continue

    details = ''
    if attempts:
        details = ' | attempted paths: {0}'.format(' || '.join(attempts))

    raise RuntimeError('unable to count {0}.{1} as {2}{3}'.format(
        owner.upper(),
        csclelement.name,
        readonly_user,
        details
    ))


def main():

    parser = argparse.ArgumentParser(
        description='Verify each readonly user can count all configured tables'
    )
    parser.add_argument('targetgdb', help='Owner target geodatabase connection (.sde)')
    parser.add_argument('--data-owner-schema', default='CSCL',
                        help='Data owner schema used when qualifying table names (default: CSCL)')
    parser.add_argument('--readonly-users-list', default='allreadonly',
                        help='Readonly user list name or file path (default: allreadonly)')
    parser.add_argument('--table-lists', default='listoftablelists',
                        help='List-of-lists name or file path for tables (default: listoftablelists)')
    args = parser.parse_args()

    logger = setup_logging(args.targetgdb)
    logger.info('starting readonly count verification of {0} at {1}'.format(
        args.targetgdb,
        datetime.datetime.now()
    ))
    logger.info('using data owner schema: {0}'.format(args.data_owner_schema))
    logger.info('readonly users list: {0}'.format(args.readonly_users_list))
    logger.info('table lists: {0}'.format(args.table_lists))

    readonly_users = read_list(args.readonly_users_list)
    list_names = read_list(args.table_lists)

    for input_conn in (args.targetgdb,):
        target_dir = os.path.dirname(input_conn)

    badkount = 0

    for readonly_user in readonly_users:

        readonly_gdb = os.path.join(target_dir, '{0}.sde'.format(readonly_user))

        if not os.path.exists(readonly_gdb):
            logger.error('FAIL:user={0} | missing connection {1}'.format(readonly_user, readonly_gdb))
            badkount += 1
            continue

        for list_name in list_names:
            object_names = read_list(list_name)

            for object_name in object_names:
                csclelement = csclelementmgr.CSCLElement(object_name)

                try:
                    kount = count_with_owner(
                        csclelement,
                        readonly_gdb,
                        args.data_owner_schema,
                        readonly_user
                    )
                except Exception as ex:
                    badkount += 1
                    logger.error('FAIL:user={0} | table={1} | {2}'.format(
                        readonly_user,
                        csclelement.name,
                        ex
                    ))
                    continue

                if int(kount) >= 0:
                    logger.info('PASS:user={0} | table={1} | count={2}'.format(
                        readonly_user,
                        csclelement.name,
                        kount
                    ))
                else:
                    badkount += 1
                    logger.error('FAIL:user={0} | table={1} | negative count {2}'.format(
                        readonly_user,
                        csclelement.name,
                        kount
                    ))

    logger.info('completed readonly count verification with {0} failures'.format(badkount))
    return badkount


if __name__ == '__main__':
    sys.exit(main())
