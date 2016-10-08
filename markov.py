#!/usr/bin/python3
import markovify
from subprocess import call
import os

script_path = os.path.dirname(os.path.realpath(__file__))
questions_file = script_path + '/piazza.txt'
if not os.path.isfile(questions_file):
    call(script_path + '/piazza_mail.rb')

with open(questions_file) as f:
    text = f.read()

text_model = markovify.Text(text)
piazza_sentences = []
for i in range(100):
    piazza_sentences.append(text_model.make_sentence(tries=100))

with open('piazza_markov.txt', 'w') as f:
    f.writelines(piazza_sentences)
