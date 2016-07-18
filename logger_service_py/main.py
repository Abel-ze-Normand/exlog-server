import socket
from datetime import datetime
from inspect import currentframe, getframeinfo
import config
import zmq

try:
    from ujson import loads as json_loads, dumps as json_dumps
except ImportError:
    try:
        from anyjson import loads as json_loads, dumps as json_dumps
    except ImportError:
        from json import loads as json_loads, dumps as json_dumps

class SdvorLoggerServiceClient:
    """
    Singleton client for SdvorLogger service. Pass in constructor URI to establish connection
    """
    __instance = None

    @staticmethod
    def instance(msg_type=''):
        if SdvorLoggerServiceClient.__instance:
            return SdvorLoggerServiceClient.__instance
        else:
            SdvorLoggerServiceClient.__instance = SdvorLoggerServiceClient(config.LOGGER_HOST, config.LOGGER_PORT, msg_type)
            return SdvorLoggerServiceClient.__instance

    def __init__(self, connection_host, connection_port, msg_type):
        context = zmq.Context()
        self.sock = context.socket(zmq.REQ)
        self.sock.connect("tcp://{0}:{1}".format(connection_host, connection_port))
        # self.sock = socket.socket()
        # self.sock.connect((connection_host, connection_port))
        self.msg_type = msg_type

    def __del__(self):
        self.sock.close()

    def prepare_string(self, string, args, level):
        frameinfo = getframeinfo(currentframe())
        try:
            string = string % args
        except:
            try:
                string = string.format(*args)
            except:
                string
        return json_dumps(dict(
            level=level,
            time=str(datetime.now()),
            funcname=currentframe().f_back.f_back.f_code.co_name,
            lineno=currentframe().f_back.f_back.f_lineno,
            message=string,
            msg_type=self.msg_type
        ))

    def info(self, string, *args):
        to_send = self.prepare_string(string, args, "INFO")
        print(to_send)
        self.sock.send(to_send.encode("utf-8"))
        self.sock.recv()

    def warning(self, string, *args):
        to_send = self.prepare_string(string, args, "WARN")
        print(to_send)
        self.sock.send(to_send.encode("utf-8"))
        self.sock.recv()

    def critical(self, string, *args):
        to_send = self.prepare_string(string, args, "CRIT")
        print(to_send)
        self.sock.send(to_send.encode("utf-8"))
        self.sock.recv()

### EXAMPLE :: then just 'from logger_service_py.main import LOGGER' anywhere in the code ###
LOGGER = SdvorLoggerServiceClient.instance("regular")
