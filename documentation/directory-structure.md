# Account Directory Structure

Over the years I've tried to fight the default directory structure and home
location on the various operating systems I work on. I wanted to not use the
default locations because they get so cluttered up with default items provided
by the operating system or generated items from apps and services running on the
system (mostly on Windows). It always ends up being more of a headache than it
was worth so now I just embrase the defaults and overlay my top level
directories and files. Below is the general structure I use today for Linux and
Windows.

> Note: `User` is the name of the directory associated with the user's account
>       or home directory.  

```
User
|-- Desktop
|-- Documents
|-- Downloads
|-- Music
|-- Pictures
|-- Videos
|-- Workspace
    |-- toolbox
        |-- scripts
        |-- templates
|-- .bashrc
|-- .bashrc.d
    |-- *custom bash snippets that get sourced by '.bashrc'.
|-- *other home files depending on the OS.
```

**Desktop**
I don't use the Desktop for any kind of file storage or organization. I may
ocassionally put a shortcut to something, but I usually prefer a clean desktop
with a visually entertaining background.  

**Documents**
I've been levereaging documents a littl bit more these days to store
non-development files.  

**Downloads**
I use Downloads all the time as a temporary dumping ground for testing things,
file transfers, and downloads. I expect everything here to be wiped out at any
point in time so I try to immediately move things to where they actually belong
if it is something I want to keep long term.

**Music**
I don't use the Music directory at this point in time.

**Pictures**
I don't use the Pictures directory at this point in time.

**Workspace**
This is my most used directory when I'm in a development environment. I
organize all my work/projects here. I also have a toolbox that is the home
of useful "tool" like scripts and templates.

**Videos**
I don't use the Pictures directory at this point in time.
