# First Segfault Server Session (ReleaseCoffee)

I used this session to get comfortable with the Segfault sandbox and a handful of essential commands. Everything below uses simple language so it is easy to audit later but still reads well in a professional context.

## Commands I Practiced

```bash
ssh root@segfault.net          # log in to the lab host (password: segfault)
cat /config/self/limits        # understand CPU/RAM/disk quotas in the sandbox
whoami && hostname && uptime   # confirm identity and how long the box has been running
id                             # show effective user/group information
df -h                          # check disk usage in human-readable form
du -sh /sec                    # measure the encrypted persistent volume
ls -la /sec                    # inspect files stored on the persistent volume
nano myfile.txt                # open a simple editor for quick edits
vi myfile.txt                  # switch to vim for modal editing practice
```

## Why These Steps Mattered

- Logging in as `root` demonstrated how Segfault grants full control—great for experimentation but a reminder to act responsibly.
- The quota commands (`cat /config/self/limits`, `df -h`, `du -sh /sec`) made it clear which resources are ephemeral versus encrypted/persistent so I do not accidentally lose work.
- Running `whoami`, `hostname`, and `uptime` is a quick triage recipe that confirms where I am connected and whether the machine has been rebooted recently.
- Practising both `nano` and `vim` ensured I can edit configuration files even if my preferred editor is not installed. I created and saved small sample files to feel the difference between the two workflows.
- I wrapped up the session by transferring a test script with `scp` (not shown above) to make sure I can pull artifacts back to my local laptop when needed.

Overall, Session 1 built muscle memory for connecting, inspecting system state, and editing files safely on a fresh Segfault instance.
