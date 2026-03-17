import datetime
import os
import smtplib
import argparse
import glob

def ConditionalEmail():
    try:
        from email.message import EmailMessage
    except ImportError:
        from email.mime.multipart import MIMEMultipart
        from email.mime.text import MIMEText

        class EmailMessage(MIMEMultipart):
            def __init__(self):
                MIMEMultipart.__init__(self)

            def set_content(self, text, subtype='plain'):
                self.attach(MIMEText(text, subtype))

    return EmailMessage()

def getlogfile(logdir
              ,logtype):

    # ex get most recent xxx-* log from a log dir with logs like
    # import.log
    # export-20210126-165353
    # qa-20210126-165300

    list_of_logs = glob.glob(os.path.join(logdir
                                         ,'{0}*.log'.format(logtype)))

    latest_log = max(list_of_logs, key=os.path.getctime)

    with open(os.path.join(logdir, latest_log), 'r') as file:
        loglines = file.read()

    return loglines


def main():
    parser = argparse.ArgumentParser(description="Send comrades notifications")

    parser.add_argument("notification",help="Subject line for the notification")
    parser.add_argument("emails",help="Comma-separated list of recipients")
    parser.add_argument("logname",help="Log type, ex 'SCHEMA.FEATURECLASS'")
    parser.add_argument("logdir",help="Directory where logs are stored")
    parser.add_argument("emailfrom",help="Email address used in From: header")
    parser.add_argument("smtpfrom",help="SMTP envelope sender")
    args = parser.parse_args()
    
    msg = ConditionalEmail()

    # notification is like "QA report for important thing (stg)"
    # in this repo we only notify on QA. Do not prepend notifications 
    # with "Completed: " or other friendly words

    content  = '{0} '.format(args.notification)
    msg['Subject'] = content
    content += 'at {0} {1}'.format(datetime.datetime.now()
                                  ,os.linesep)

    if args.logname == 'NOLOG':
        # NOLOG is args.logname on catastrophic failures. NA in this repo I think 
        content = 'FAIL. No evidence to report. Check the logs in {}'.format(args.logdir)
        msg.set_content(content) 
    else: 
        content += '\n' + getlogfile(args.logdir
                                    ,args.logname)  
        if 'WARNING' in content or 'ERROR' in content:
            # report log details
            msg.set_content(content) 
        else:
            # we dont need the log, keep it simple
            msg.set_content('PASS. We found no evidence that the external dataset differs from CSCL.') 
    
    smtp = smtplib.SMTP(args.smtpfrom)  
    msg['From'] = args.emailfrom
    # this is headers only 
    # if a string is passed to sendmail it is treated as a list with one element!
    msg['To'] = args.emails
  
    try:
        smtp.sendmail(msg['From']
                     ,msg['To'].split(",")
                     ,msg.as_string())
    except smtplib.SMTPRecipientsRefused as e:
        print("\n notify.py - Email not sent: relaying denied.")
        print(" notify.py - This is expected from desktop environments.\n")

    smtp.quit()


if __name__ == "__main__":
    main()

