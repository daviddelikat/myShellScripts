#!/bin/env perl

use strict;
use warnings;

package My::NotePad;

use Tk;
use Moose;
use MooseX::GUI;

extends MooseX::GUI::Form;

has searchField => (
     isa => 'textField',
     events => {
         onChange => 'searchField::onChange',
	 onExit => 'searchField::onExit',
	 onEnter => 'searchField::onEnter',
     },
     style => {
	 fillRow => 1,
     }
);

has noteArea => (
    isa => 'textArea',
    contents => '_currentNote',
    events => {
        onChange => 'noteArea::onChange',
	onExit => 'noteArea::onExit',
	onEnter => 'noteArea::onEnter',
    },
    style => {
	fillRow => 1,
	fillColumn => 1,
    }
);

has notes => (
    isa => 'indexedSet[My::Note]',
);

has saveButton => (
    isa => 'button',
    events => {
        press => 'saveButtonPress',
    },
    style => {
        icon = 'file://path/to/saveIcon.icn',
    }
);

has newButton => (
    isa => 'button',
    events => {
        press => 'newButtonPress',
    },
    style => {
        icon = 'file://path/to/newIcon.icn',
    }
);

has configButton => (
    isa => 'button',
    events => {
        press => 'configButtonPress',
    },
    style => {
        icon = 'file://path/to/configIcon.icn',
    }
);

has config => (
    isa => 'hash',
    elements => {
        autosave => [
	    isa => 'integer',
	    label => 'Auto Save Notes',
	    hint => "enter zero to never save\n >0 to save every n seconds",
	    default => 30,
	],
	saveloc => [
	    isa => 'url'
	    label => 'Store Notes at URL:',
	    hint => "enter a url or path where notes can be stored/retrieved\n"
	            "http[s]: urls will get/post note data",
	    default => "file://$HOME",
	],
    },
    builder => '_loadConfig',
);

arrangeForm grid =>
    [ qw/searchField / ],
    [ qw/noteArea / ],
    [ qw/saveButton newButton configButton/ ],
;

sub saveButtonPress {
    my $self = shift;
    my $form = shift;
    $form->notes->current->save;
}

sub deleteButtonPress {
    my $self = shift;
    my $form = shift;
    # TODO confirm delete note
    # MAYBE move note to trash
    # MAYBE use config flag to select trash
    $form->notes->current->delete;
}

sub newButtonPress {
    my $self = shift;
    my $form = shift;
    $form->notes->new->makeCurrent;
}

sub configButtonPress {
    my $self = shift;
    my $form = shift;
    Moose::GUI::Form->new->init {
	my $self = shift->arrangeWithGrid;
        for my $field ( $form->config->fields ) {
	    $self->add $form->labeledTextField->newFrom $field;
	    $self->nextRow;
	}
	$self->cancelButton->saveButton;
    }->show;
}

package searchField;

sub onChange {
   my $self = shift;
   my $form = shift;
   my $event = shift;
   return if $self->content->length < 3 ;
   $form->searchResults $form->notes->search($self->content);
}

sub onEnter {
   my $self = shift;
   my $form = shift;
}

sub onExit {
   my $self = shift;
   my $form = shift;
}

package noteArea;

my $lastSave;
sub onChange {
   my $self = shift;
   my $form = shift;
   # check for autosave; save if required
}

sub onEnter {
   my $self = shift;
   my $form = shift;
   $lastSave = undef;
}

sub onExit {
   my $self = shift;
   my $form = shift;
   # if autosave...
}

My:NotePad->show;

