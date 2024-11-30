# GHCR Connection

![Alt Text](https://gist.github.com/yokawasa/841b6db379aa68b2859846da84a9643c)

## 1. PAT Creation  

1. Settings > Developer Settings > Personal Access Toten > Token(classic)  

2. When generating the new token, you'll need additional scopes compared to a personal repository  

- read:packages and write:packages - for basic package operations  
- delete:packages if you need to delete packages  
- repo for accessing private repositories  
- Most importantly, you need write:org or admin:org to manage organization packages  

## 3. Checking if PAT is set in your environment  

```sh
echo "PAT value: ${PAT:-not set}"
```

- If this shows "not set" or empty, you'll need to set the PAT variable first.  

```sh
export PAT='your_pat_value'
```

## 4. Logging in to ghcr on your account and organisation  

**Personal GH Account**  

```sh
docker login ghcr.io -u your_username --password-stdin <<< "$PAT"
```

- <<< feeds the PAT into the docker login command  

**Using organisation**  

```sh
docker login ghcr.io -u latcaa-ce-ntu --password-stdin <<< "$PAT"
```

## 5. Pulling Organisation's Container Registry on GitHub  

**Pulling of Images off GHCR**  

```sh
docker pull ghcr.io/latcaa-ce-ntu/your-image-name:tag
```
