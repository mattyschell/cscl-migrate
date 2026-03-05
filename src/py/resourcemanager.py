import os
class listmanager(object):

    # why is this little thing a class :0) clown?
    # todo: refactor this

    def __init__(self
                ,whichlist):

        with open(os.path.join(os.path.dirname(__file__)
                              ,'resources'
                              ,whichlist)) as l:
            
            contents = [line.strip() for line in l if line.strip()]

        self.names = contents