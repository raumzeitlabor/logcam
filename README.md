busybox-extra tar cf - /www/* | busybox-extra 172.22.37.45 4223
nc -l -p 4223 | tar x
