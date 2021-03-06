# time-control

time-control is a tool for controlling time spent on each task. It suports syntax for setting start and end time for each task. The idea is to show you where your time is being spent, which is not always so clear.

Documentation
-------------

See [GETTING_STARTED](https://github.com/leocampos/time-control/blob/master/GETTING_STARTED.md) for information on starting up the app.

How to use
----------

First of all you'll be asked for a task:

Task:

### Regular Task
Enter the text which represents to you a task name, example:
reading email, or perhaps having coffee
Press enter

Every task you enter will store its start time. Let's say it's 10:04 AM and you type "Meeting with Joe"
The meeting will only be considered finished when you enter another task, say "Having coffee" and so on
* * *
### Exiting the App closing last task
What happens if it is the end of the day and you want to close last task before leaving?
Just type "exit", "quit" or "abort" and you'll exit the program closing last task with actual time.

* * *
### Tagging the content
A good way to organize your tasks is to label them with tags, this is done in a very similar manner of twitter
hash tags.

So in order to use a tag, you should mark it with a hash symbol: #work #leisure #other

As it can be noticed from the example above, it must be separated by any number of spaces.

Example:
meeting with john #business #real_state

* * *
### Setting the start time
Another possibility is that you forgot to put a task for lunch, this meant you left an open task which
took 15 minutes, as a long 1 hour and 15 minutes task. How to put an afterwards task in its due place?

You have some options:
One of them is just tell it has started some time ago, example

**Lunch -1h**

This means Lunch task started 1 hour ago (it could be expressed in *m*inutes, *d*ays, *s*econds)
It could also be set to the future, just using a plus sign instead of a minus one.

One other option is to give a specific time:

**Lunch 12**

This means Lunch task started exacty at noon (it could also have been expressed as 1200 or 12:00), it is important
to notice that time options must be the last thing used:

* * *
### Setting the end time
On this matter, it is also possible to set the task end time, but for this one you first need to give an initial time:

**Lunch 12-13**

This means Lunch task started exacty at noon and ended at 13:00 (it could also have been expressed as 1200-13, 12:00-13, 12-1300, 12-13:00, 12:00-1300, 12:00-13:00)

* * *
### Examples
valid examples:

**meeting with joe -5m**

- Started 5 minutes ago

**meeting with joe 11**

- Started at exactly eleven o'clock

**meeting with joe 1104**

- Started at exactly 11:04h

**meeting with joe 11:04**

- Started at exactly 11:04h

**meeting with joe 1104-13**

- Started at exactly 11:04h and ended at 13:00h

**meeting with joe 1104-13:05**

- Started at exactly 11:04h and ended at 13:05h

**meeting with joe 1104-1305**

- Started at exactly 11:04h and ended at 13:05h

**meeting with joe 11:04-13:05**

- Started at exactly 11:04h and ended at 13:05h

**meeting with joe 11:04-1305**

- Started at exactly 11:04h and ended at 13:05h

**meeting with joe #work #boring 1104-13:05**

- Started at exactly 11:04h and ended at 13:05h and is labeled with two tags: work and boring

**meeting with joe #work #boring 1104-1305**

- Started at exactly 11:04h and ended at 13:05h and is labeled with two tags: work and boring

**It is important to notice that you must pay attention when you set specific times, because the system will fit the recently created task among the former ones, if this means updating or even deleting tasks in the timeline, it will be done so.**