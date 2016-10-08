#!/usr/bin/python3
import markovify
from subprocess import call
import os
from sys import argv

script_path = os.path.dirname(os.path.realpath(__file__))
questions_file = script_path + '/Piazza.txt'

def update_mail():
    call(script_path + '/piazza_mail.rb')

def ask_question(str_end='\n'):
    with open(questions_file) as f:
        text = f.read()
    text_model = markovify.Text(text)
    markov = text_model.make_short_sentence(100)
    print(markov, sep='', end=str_end)

if __name__ == '__main__':
    times = 1
    if len(argv) > 1:
        try:
            times = int(argv[1])
        except ValueError:
            pass

    if '--force-update' in argv or not os.path.isfile(questions_file):
        update_mail()

    if '--no-return' in argv:
        str_end = ''
    else:
        str_end = '\n'

    for i in range(0, times):
        ask_question(str_end=str_end)

