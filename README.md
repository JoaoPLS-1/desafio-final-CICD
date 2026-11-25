# Desafio final CI/CD

Site estático de JoaoPLS-1 servido com Nginx. Repositório: https://github.com/JoaoPLS-1/desafio-final-CICD.

## Validação

```powershell
node scripts/validate.mjs
```

O GitHub Actions valida o HTML, constrói a imagem e compara o HTML e o CSS recebidos por HTTP com os arquivos do commit. O rodapé é obrigatório quando VERSION contém 1.0.

## Questão 1 — branch e Pull Request

A base é criada na main porque o repositório começou vazio. A entrega final adiciona o rodapé em feature/entrega-final. O PR só deve ser integrado depois do CI verde.

```powershell
git switch -c feature/entrega-final
# Adicionar o rodapé e atualizar VERSION para 1.0.
git add index.html VERSION
git commit -m "feat: adiciona rodapé da versão final 1.0"
git push -u origin feature/entrega-final
```

## Questão 2 — sincronização

Depois do merge do PR no GitHub:

```powershell
git switch main
git pull --ff-only origin main
git rev-parse HEAD
git rev-parse origin/main
git status --short
```

Os SHAs devem ser iguais e o diretório deve estar limpo.

## Questão 3 — imagem oficial no GHCR

O proprietário e o nome da imagem usam letras minúsculas. Use um token com write:packages; nunca salve o token no Git nem o informe em argumentos. No PowerShell, com GHCR_TOKEN já definido na sessão:

```powershell
$env:GHCR_TOKEN | podman login ghcr.io -u JoaoPLS-1 --password-stdin
$revision = git rev-parse HEAD
podman build --format docker --file Containerfile --build-arg "VCS_REF=$revision" --tag ghcr.io/joaopls-1/desafio-final-cicd:1.0 --tag ghcr.io/joaopls-1/desafio-final-cicd:latest .
podman push ghcr.io/joaopls-1/desafio-final-cicd:1.0
podman push ghcr.io/joaopls-1/desafio-final-cicd:latest
```

A imagem contém o rótulo OCI que a vincula a este repositório. Para o acesso sem autenticação de colegas, configure a visibilidade do pacote como pública nas configurações do GitHub Packages. Caso contrário, cada colega precisará de permissão de leitura e login.

## Questão 4 — baixar e executar

Remova apenas os containers e as imagens criados para esta entrega. Preserve recursos de outras atividades. Não execute prune indiscriminadamente.

```powershell
# Se houver um container anterior desta entrega:
# podman rm -f entrega-final
podman rmi ghcr.io/joaopls-1/desafio-final-cicd:1.0 ghcr.io/joaopls-1/desafio-final-cicd:latest
podman run --detach --pull=always --name entrega-final --publish 9000:80 ghcr.io/joaopls-1/desafio-final-cicd:1.0
Invoke-WebRequest http://localhost:9000/ -UseBasicParsing
Start-Process http://localhost:9000/
```

O --pull=always exige consulta ao Registry, mesmo se houver cache. O site deve exibir o rodapé da versão final. A verificação compara também o conteúdo servido com index.html.

## Questão 5 — imagem de colega

Etapa opcional, depende de um endereço real fornecido por um colega. Exemplo a substituir (não é uma imagem real):

```powershell
podman run --detach --pull=always --name site-colega --publish 9001:80 ghcr.io/USUARIO-DO-COLEGA/IMAGEM:TAG
Start-Process http://localhost:9001/
```

Não é necessário copiar arquivos entre computadores. Não há alegação de conclusão desta etapa sem executar uma imagem real do colega.

## Publicação alternativa sem PAT local

O workflow Publicar imagem GHCR pode ser iniciado manualmente na main pela aba Actions. Ele usa GITHUB_TOKEN temporário com packages:write, testa a imagem e envia as tags 1.0 e latest. Isso permite publicar sem colocar um PAT no computador. A credencial do Git Credential Manager desta máquina autenticou no GHCR, mas seu push foi recusado por falta do escopo write:packages; portanto, a publicação pelo Actions substitui esse push local nesta entrega.

## Registro da execução

- PR da questão 1: https://github.com/JoaoPLS-1/desafio-final-CICD/pull/1, integrado após CI verde.
- Main atualizada com git pull --ff-only e verificação de igualdade com origin/main.
- Questão 5 dispensada pelo usuário por não haver uma imagem de colega informada.
