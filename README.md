# claude-code-researcher


## docker container operations

### installing the docker container

```bash
docker compose up -d

docker exec -it -u happy ccr bash
```

### `ssh` into the docker container

```bash
ssh -p 2222 happy@localhost
# when prompted for password, just hit `Enter`
```

## project development

### installing skills for the repo

```bash
npx skills install
```
