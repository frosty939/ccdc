# CCDC Stuff

<table style="width:50%; display: inline-block">
	<th colspan="2" align="center">
		Tips, Tricks, and Checklists
	</th>	
		<tr>
		<td align="center">
			<img src="https://www.redhat.com/favicon.ico" hspace="10" height="12" width="12"></img>
			<a href="https://docs.google.com/document/d/1YkQXj60AR4s7KLYcbZ8ur4Sd8Hkp31v4vk6iN-ACICE">
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
</table><table style="width:50%; display: inline-block">
	<th colspan="2" align="center">
		Box Assignments
	</th>
		<tr>
		<td align="center">
			<a href="https://docs.google.com/document/d/1YkQXj60AR4s7KLYcbZ8ur4Sd8Hkp31v4vk6iN-ACICE">
			CCDC 2019
			</a>
		</td>
		</tr>
</table>

### [CCDC Box Assignments](https://docs.google.com/spreadsheets/d/1qehcr-z5UUX4_o3SxmbtM5GyRGJjXqPVMIITtHcLucs)

---

### Global backupDir Variable
Short and easy, but prone to failures

> `backupDir="$HOME""/ccdc_backups/$(basename -s.sh "$0")"`

A bit more of a pain, but significantly less prone to failures

> `backupDir="$HOME""/ccdc_backups/$(echo $BASH_SOURCE | sed 's|.sh$||' | rev | cut -d\/ -f1 | rev)"`
