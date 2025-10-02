# Workshop Quick Start 

## Clone the repo
Run these commands to make a local copy of the repo:
```bash
git clone https://github.com/wyattcsutherland/characterization-mutation-kata-hangar.git
cd characterization-mutation-kata-hangar
```

## Create your own branch

Replace with your name (never work directly on main):

```bash
git switch -c checkin/<firstname>-<lastname>
```

## Make small commits as you work

Commit early and often:
```bash
git add -A
git commit -m "rename variable for clarity"
```

## Push your branch to GitHub

Push your branch to GitHub so it shows up in the repo:

```bash
git push -u origin HEAD
```

## Run tests often

Keep your feedback loop fast:

```bash
# tests
./gradlew test
# mutation tests
./gradlew pitest
# or "verifyAll" runs both tests in order
./gradlew verifyAll
```

## Bonus: Count your commits

Before leaving the workshop, run this to see how many commits you've made on your branch

```bash 
git rev-list --count main..HEAD
```

## Reset if you get stuck

Return to the starting point with tags:

```bash
git fetch --tags
git switch -C reset v0-start
```
