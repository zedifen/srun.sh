# srun.sh

Ported from [Python version in this gist](https://gist.github.com/fernvenue/36bcd3a3b562a00c5aec3e58387d9b3b).

Also see issue <https://github.com/syimyuzya/tunet-cli/issues/6>, which contains a JavaScript for authentication.

Some article on analyzing this authentication process can be seen at <https://zhuanlan.zhihu.com/p/122556315> and <https://blog.csdn.net/qq_41797946/article/details/89417722>.

Configurable script inputs:

| Variable Name      | Description                                         | Default Value  |
| ------------------ | --------------------------------------------------- | -------------- |
| `MY_NET_INTERFACE` | Name of the network interface to get IP address on. | `eth4`         |
| `SRUN_AUTH_HOST`   | Hostname of the authentication site.                | `10.210.2.100` |
| `AUTH_USERNAME`    | Username used for authentication.                   | `username`     |
| `AUTH_PASSWORD`    | Password used for authentication.                   | `password`     |

Variables above can be set on the fly when running the script:

```
AUTH_USERNAME="xiaoming" AUTH_PASSWORD="123456" bash srun.sh
```

Default UA is currently hardcoded in the script as `MY_USER_AGENT`. Edit it if it's necessary.

