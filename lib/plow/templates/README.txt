$ tree sites/
sites/
|-- README
`-- example.ryansobol.com
    |-- log
    |   `-- apache2
    |       |-- access.log
    |       `-- error.log
    `-- public
        `-- index.html

4 directories, 4 files

$ ls -hal sites/example.ryansobol.com/log/apache2/
total 196K
drwxr-x--- 2 root GROUP 4.0K Sep  5 03:11 .
drwxr-xr-x 3 USER GROUP 4.0K Sep  5 03:09 ..
-rw-r----- 1 root GROUP 136K Sep  9 11:10 access.log
-rw-r----- 1 root GROUP  48K Sep  9 09:06 error.log
