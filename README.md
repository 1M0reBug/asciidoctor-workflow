# Asciidoctor-workflow

This is a simple starter project to use gitlab-ci or travis to continuously build asciidoc work, into
all the format handled by asciidoctor.

## Using Travis

Follow http://mgreau.com/posts/2016/03/28/asciidoc-to-gh-pages-with-travis-ci-docker-asciidoctor.html
to prepare the repo in order to use travis for the continuous build.

Basically it builds in HTML/PDF/EPUB/MOBI and push it to the gh-pages branch.

it needs

+ `GH_USER_NAME`: the registered username in the repo
+ `GH_USER_EMAIL`: the registered email in the repo
+ `GH_TOKEN`: a token to automate the push
+ `GH_REF`: the url of the repo
