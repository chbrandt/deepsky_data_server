# Swift DeepSky data-server

Server-side infrastructure to handle DeepSky data uploaded and automated publishing.

## Setup

Have `incrontab` ("[inotify cron](https://inotify.aiken.cz/?section=incron&page=about&lang=en)") installed and add to its table the `.../deepsky_data_server/upload/`.

In particular, if supervising inotify's `IN_MODED_TO` events:
```bash
$ incrontab -l
/path/to/deepsky/upload   IN_MOVED_TO   /path/to/deepsky/bin/incron_trigger.sh   $%   $#   $@
```

Where `$%`, `$#`, `$@` are placeholders for [event-related flag, filename, path](https://linux.die.net/man/5/incrontab)

/.\ 
