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
    __instances = dict()

    @staticmethod
    def instance(msg_type="regular"):
        # client and server will now support any type of messages
        inst = __instances.get(msg_type)
        if not inst:
            inst = __instances[msg_type] = SdvorLoggerServiceClient(config.LOGGER_HOST, config.LOGGER_PORT, msg_type)
        return inst

    def __init__(self, connection_host, connection_port, msg_type):
        addr = socket.gethostbyname(connection_host)
        context = zmq.Context()
        self.sock = context.socket(zmq.REQ)
        self.sock.connect("tcp://{0}:{1}".format(addr, connection_port))
        self.msg_type = msg_type

    def __del__(self):
        self.sock.close()

    def prepare_string(self, string, args, level):
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
LOGGER = SdvorLoggerServiceClient.instance(msg_type = "regular")
