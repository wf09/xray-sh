# -*- coding: utf-8 -*-
"""
Install Xray on Linux
"""
import os
import platform
from colorama import init, Fore, Back, Style

init(autoreset=True)
print("我是我")

# check platform type
system_type = platform.system()
print(f"You are running on {system_type}")
if 'Windows' in system_type:
    print(f'{Fore.RED}The script does not support windows.')
    print(f'{Fore.RED}Exited.')
    # exit(-1)

# if Linux
# linux_info = os.popen("cat /etc/os-release").readlines()

linux_infos = os.system('apt update')
# print(linux_infos)
# for linux_info in linux_infos:
#
#     if 'ubuntu' or 'debian' in linux_info:
#         linux_distribution = 'debian'
#         break
#     else:
#         linux_distribution = 'centos'
#         break
# print(f'Your linux distribution is {linux_distribution}')
