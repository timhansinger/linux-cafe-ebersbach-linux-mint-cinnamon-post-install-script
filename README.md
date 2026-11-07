# linux-cafe-ebersbach-linux-mint-cinnamon-post-install-script

A post install script for Linux Mint Cinnamon to set specific system settings and install specific applications

To run the post install script execute:

```bash
./run.sh

# Dry-run:
# ./run.sh --dry-run

# Show the help:
# ./run.sh --help
```

During development to just test a specific feature:

```bash
bash -c '. "./features/software_okular.feature.sh" && run_feature'
```
