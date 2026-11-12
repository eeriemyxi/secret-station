+++
title = "My Experience with Mechvibes"
date = "2023-10-27"
tags = ["keyboard", "mechvibes", "mechvibes lite", "electron"]
+++

For the longest time in my life, I never got to own a mechanical keyboard for financial reasons. You will be correct if you guess that I have a low-end laptop for the same reason: financial complications. But I always wanted that clicky sound that a mechanical keyboard in general gives you.

One day, I discovered Mechvibes. It was some software that presses sounds on every press of your keyboard; to be more specific, it plays the sounds of mechanical keyboard key presses/switches. It was wonderful and worked really well. The default themes were all very nice, and the interface of the app was nice too. There were no bugs either. But it had one major problem: it was based on Electron.

# Criticism 
I opine that Electron is meant for bigger projects. Even if Mechvibes is very useful, it does not change the fact that, in the end, it's just an audio player. I don't expect my audio player to cost me three hundred megabytes of used RAM out of my little RAM storage of just four GB (three and a half, to be precise!).

# How I Resolved This Problem
Luckily, I am not bad at Python. So I created a Python version of this app and named it Mechvibes Lite. The useful thing about my version is that it tries to mimic the original version; you can run the themes that were created for Mechvibes. It is far less heavy on computer resources because it doesn't even render a graphical interface. It can work without any graphical interface, from your favourite shell.

# References
- Mechvibes
    - https://mechvibes.com/
    - https://github.com/hainguyents13/mechvibes/
- Mechvibes Lite
    - https://github.com/eeriemyxi/mechvibes-lite
