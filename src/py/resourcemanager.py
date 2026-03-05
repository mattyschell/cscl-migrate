import os
class listmanager(object):

    def __init__(self
                ,whichlist):

        with open(os.path.join(os.path.dirname(__file__)
                              ,'resources'
                              ,whichlist)) as l:
            
            contents = [line.strip() for line in l if line.strip()]

        self.names = contents