I really enjoy the "manual-ness" of Linux, in the same way that driving stick-shift gives you finer control of the vehicle, or the way that riding a fixed gear bicycle gives you a feel for how your bike is making contact with the road. I was on my work laptop, and my screen was too bright. It's late at night and I want to shift it towards a yellow tint. Remove the blue lights and your sleep will be better, they say.

Two commands! That's all it took to accomplish the task.

```
pacman -S redshift
```

This installs the open source program, redshift. Go ahead, feast your eyes on its magnificent code: https://github.com/jonls/redshift
It's a wonderful program which lets you control the tint of your screen.

The second command sets the screen to something akin to candle light, or a color temperature of 3400K. That brings me to my next command, in which I specified that exact color temperature: 

```redshift -o 3400```

Wonderful! My screen was now at a perfect color temperature for coding in the evening.

Except... the screen is too bright.

I need to invoke the xbacklight command. It adjusts my screen brightness.

I use i3 as a window manager, which means that I had to manually add these to the configuration:

```
bindsym XF86MonBrightnessUp exec --no-startup-id xbacklight -inc 2
bindsym XF86MonBrightnessDown exec --no-startup-id xbacklight -dec 2
```

This binds my keyboard's backlight buttons, so that they issue commands to the xbacklight utility and either increase or decrease the backlight by 2%.

At this point I wouldn't blame you for saying to yourself, "What a pain in the ass. Who bothers to map their keyboard keys to their favorite screen brightness utility?"

But I say to you, this is a most beautiful way to meld with your operating system. Linux can be a wonderfully sparse toolset, and a blank canvas on which to develop your aesthetics.

If this piqued your interest and you'd like to discuss it further, please get at me via twitter @mrashkovsky or email (same handle, @gmail.com).



Linux terminal log, for the curious:
```
mike@haifa [02:36:50 AM] [~] 
-> % sudo pacman -S redshift         
[sudo] password for mike: 
warning: redshift-1.12-1 is up to date -- reinstallin
resolving dependencies...
looking for conflicting packages...

Packages (1) redshift-1.12-1

Total Installed Size:  0.83 MiB
Net Upgrade Size:      0.00 MiB

:: Proceed with installation? [Y/n] Y
(1/1) checking keys in keyring                     [#
(1/1) checking package integrity                   [#
(1/1) loading package files                        [#
(1/1) checking for file conflicts                  [#
(1/1) checking available disk space                [#
:: Processing package changes...
(1/1) reinstalling redshift                        [#
:: Running post-transaction hooks...
(1/3) Updating icon theme caches...
(2/3) Arming ConditionNeedsUpdate...
(3/3) Updating the desktop file MIME type cache...
mike@haifa [02:37:12 AM] [~] 
-> % redshift -O 3400
Using method `randr'.
mike@haifa [03:22:31 AM] [~] 
-> % 
mike@haifa [03:22:34 AM] [~] 
-> % xbacklight -set 5  
mike@haifa [03:22:43 AM] [~] 
-> % xbacklight -set 5  
mike@haifa [03:22:47 AM] [~] 
-> % xbacklight -set 15 
mike@haifa [03:22:51 AM] [~] 
-> % 
```
