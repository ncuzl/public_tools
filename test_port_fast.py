#-*- coding: UTF-8 -*-
'''
限定时间内测试端口是否可用
by zhongliang
email 8201683@qq.com
'''

import socket
import errno
from time import time as now


def wait_net_service(server, port, timeout=None):
    s = socket.socket()
    end = timeout and now() + timeout

    while True:
        try:
            if timeout:
                next_timeout = end - now()
                if next_timeout < 0:
                    return False
                else:
                    s.settimeout(next_timeout)

            s.connect((server, port))

        except socket.timeout, err:
            if timeout:
                return False

        except socket.error, err:
            if type(err.args) != tuple or err[0] not in (errno.ETIMEDOUT, errno.ECONNREFUSED):
                raise
        else:
            s.close()
            return True
        
if wait_net_service("www.baidu.com", 80, 0.1):
    print 'online'
else:
    print 'offline'
