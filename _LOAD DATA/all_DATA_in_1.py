# collects all sql data files to one file

from os import listdir
from os.path import isfile
sql_files = [f for f in listdir() if isfile(f) and f.endswith('.sql') and not f.startswith('all_DATA')]
n = 0

with open('all_DATA.sql', 'w', encoding='UTF-8') as all_DATA:
    for f in sql_files:
        print(f)
        with open(f, 'r', encoding='UTF-8') as f1:
            for line in f1.readlines():
                n += 1
                all_DATA.writelines(line)

print(n)
