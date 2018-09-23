# -*- coding: utf-8 -*-
"""
    Wombat256Mod Colorscheme
    ~~~~~~~~~~~~~~~~~~~~~~~~

    Converted by Vim Colorscheme Converter
"""
from pygments.style import Style
from pygments.token import Token, Comment, Name, Keyword, Generic, Number, Operator, String

class Wombat256ModStyle(Style):

    background_color = '#242424'
    styles = {
        Token:              'noinherit #e3e0d7 bg:#242424',
        Comment:            'noinherit #9c998e italic',
        Name.Attribute:     'noinherit #cae982',
        Name.Entity:        'noinherit #eadead',
        Comment.Preproc:    'noinherit #e5786d',
        Keyword:            'noinherit #88b8f6',
        Name.Tag:           'noinherit #88b8f6',
        Generic.Inserted:   'bg:#2a0d6a',
        Number:             'noinherit #e5786d',
        Name.Variable:      'noinherit #cae982',
        Name.Function:      'noinherit #cae982',
        String:             'noinherit #95e454 italic',
        Generic.Traceback:  '#ff2026 bg:#3a3a3a bold',
        Generic.Heading:    '#ffffd7 bold',
        Generic.Deleted:    'noinherit #242424 bg:#3e3969',
        Keyword.Type:       'noinherit #d4d987',
        Generic.Subheading: '#ffffd7 bold',
        Name.Constant:      'noinherit #e5786d',
    }
