# CCDC Stuff

<table style="width:50%; display: inline-block">
	<th colspan="2" align="center">
		Tips, Tricks, and Checklists
	</th>
	<tr>
		<td align="center">
			<img src="https://www.redhat.com/favicon.ico" hspace="10" height="12" width="12"></img>
			<a href="https://docs.google.com/document/d/1YkQXj60AR4s7KLYcbZ8ur4Sd8Hkp31v4vk6iN-ACICE" target="_blank">
			RHEL / CentOS
			</a>
			<img src="https://www.centos.org/favicon.ico" hspace="10" height="12" width="12"></img>
		</td>
		<td align="center">
			<img src="https://www.debian.org/favicon.ico" hspace="10" height=12 width=12></img>
			<a href="https://docs.google.com/document/d/1NCHm0c6p9uX0tFr1_uNoTgpCEvhJta3HaEGocwuElaY">
			Debian / Ubuntu
			</a>
			<img src="https://assets.ubuntu.com/v1/cb22ba5d-favicon-16x16.png" hspace="10" height=12 width=12></img>
		</td>
	</tr>
</table>
<table style="width:50%; display: inline-block">
	<th colspan="2" align="center">
		CCDC Event
	</th>
	<tr>
		<td align="center">
			<a href="https://docs.google.com/spreadsheets/d/1qehcr-z5UUX4_o3SxmbtM5GyRGJjXqPVMIITtHcLucs">
			Box Assignments (2019)
			</a>
		</td>
		<td align="center">
			<a href="https://docs.google.com/document/d/11sx-cXRJJezIBISARB1U_ArjBxWZ4e9UZl6FHYWTmLE">
			Fundamentals (2019)
			</a>
		</td>
	</tr>
	
</table>
<table style="width:50%; display: inline-block">
	<th colspan="2" align="center">
		How To's
	</th>
	<tr>
		<td align="center">
			<a href="https://docs.google.com/document/d/1NL-SGj7-67IxfBYOCrEdMwD7ZK0YZG3FfTGg9NReGVU">
			Splunk (CentOS 6)
			</a>
		</td>
		<td align="center">
			<a href="https://docs.google.com/document/d/11b5CYBTm4d0Urpi7CnDx-kcfcL0PqrDaLZiyBy44zyw">
			Bind9 (Ubuntu 12.04)
			</a>
		</td>
	</tr>
	
</table>

---

### Helpful PS1 ###
```
PS1="┌─[\`if [ \$? = 0 ]; then echo \[\e[32m\]✔\[\e[0m\];else echo \[\e[31m\]✘\[\e[0m\];fi\`]───[\`if [ \u = root ]; then echo \[\e[31m\]\u\[\e[0m\]; else echo \[\e[33m\]\u\[\e[0m\]; fi\`\[\e[01;49;39m\]@\H\[\e[00m\]]───[\[\e[1;49;34m\]\W\[\e[0m\]]───[\[\e[1;49;39m\]\$(ls | wc -l) files, \$(ls -lah | grep -m 1 total | sed 's/total //')\[\e[0m\]]\n└───▶ "
```

### Global backupDir Variable
Short and easy, but prone to failures

> `backupDir="$HOME""/ccdc_backups/$(basename -s.sh "$0")"`

A bit more of a pain, but significantly less prone to failures

> `backupDir="$HOME""/ccdc_backups/$(echo $BASH_SOURCE | sed 's|.sh$||' | rev | cut -d\/ -f1 | rev)"`
