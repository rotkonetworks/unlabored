To run the commands inside a screen session to avoid any risk of SSH connection issues, you can do the following:

SSH into evmos01:

```bash
ssh evmos01
```

Start a screen session:

```bash
screen -S evmos_sync
```

Now, within the screen session, perform the steps as follows:

Perform an initial sync without stopping the services:

```bash
rsync -azvhP /opt/evmos/data evmos02:/opt/evmos/
```

Stop the services on both servers and perform the final sync with the --delete flag:

```bash
systemctl stop evmosd && ssh evmos02 'systemctl stop evmosd' && rsync -azvhP /opt/evmos/data evmos02:/opt/evmos/data --delete
```

Start the services on both servers:

```bash
systemctl start evmosd && ssh evmos02 'systemctl start evmosd'
```

If you need to detach from the screen session without stopping the commands, press Ctrl-a d. To reattach to the session, use the following command:

```bash
screen -r evmos_sync
```

By running these commands inside a screen session, you can safely perform the synchronization even if your SSH connection drops. The commands will continue to run in the background.

To measure progress from your home machine by comparing 2 different disks, you can use following script:
```bash
src_usage=$(ssh evmos01 df | grep "disk-1" | awk '{print $3}' &)
dst_usage=$(ssh evmos02 df | grep "disk-1" | awk '{print $3}' &)
wait
echo "$dst_usage / $src_usage"
echo "scale=4; ($dst_usage/$src_usage)*100" | bc
```
