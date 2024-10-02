# -*- coding: utf-8 -*-
# ===============================================================
#   @author: 易流锋
#   @date: 2022/8/27 18:29
#   @File : controller.py
#   @des: 
# ================================================================
import json
import logging
import os
import time
import hashlib
from config import DEFAULT_CONFIGS
from Server.commands import keyboard_control, mouse_control, input_msg, speak, command_apply
from util.volume import volume_up,volume_down,volume_mute

'''
{
    "type": "mouse"   # mouse、keyboard、volume
    "action": ""
    "data": ""
}
'''

def handler(message):
    # print(body)
    try:
        if message['type'] == 'mouse':
            mouse_control(message)
        elif message['type'] == 'command':
            command_apply(message)
        elif message['type'] == 'volume':
            if message['action'] == 'up':
                volume_up()
            elif message['action'] == 'down':
                volume_down()
            elif message['action'] == 'mute':
                volume_mute()
        elif message['type'] == 'keyboard':
            pass
    except:
        logging.error(f'message is wrong! {message}')


    # 将内容分成两部分
    # 1. 控制命令
    # 2. 动态密码：内容MD5+时间->动态密码
    # if body['type'] == 'command_list':
    #     # 进行hash校验
    #     text = json.dumps(body['content'], ensure_ascii=False, separators=(',', ':')) + str(int(time.time()) // 120) + \
    #            DEFAULT_CONFIGS['password']
    #     for item in body['content']:
    #         print(item)
        # check_sum = hashlib.md5(text.encode('utf-8')).hexdigest()
        # if body['check_sum'] == check_sum:
        #     for item in body['content']:
        #         handler_command(item)
        # else:
        #     logging.error(text)
        #     logging.error('校验失败')
    # if body['type'] == 'command':
    #     command = json.loads(body['content'])
    #     handler_command(command)
    # elif body['type'] == 'command_list':
    #     command_list = json.loads(body['content'])
    #     for command in command_list:
    #         handler_command(command)
