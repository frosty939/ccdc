# CCDC Stuff

---

### [Debian / Ubuntu Tips & Tricks](https://docs.google.com/document/d/1NCHm0c6p9uX0tFr1_uNoTgpCEvhJta3HaEGocwuElaY)

---

### [CCDC Box Assignments](https://docs.google.com/spreadsheets/d/1qehcr-z5UUX4_o3SxmbtM5GyRGJjXqPVMIITtHcLucs)

---

### Global backupDir Variable
Short and easy, but prone to failures

> `backupDir="$HOME""/ccdc_backups/$(basename -s.sh "$0")"`

A bit more of a pain, but significantly less prone to failures

> `backupDir="$HOME""/ccdc_backups/$(echo $BASH_SOURCE | sed 's|.sh$||' | rev | cut -d\/ -f1 | rev)"`
