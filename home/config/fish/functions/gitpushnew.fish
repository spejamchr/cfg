
function gitpushnew
  set BRANCH $(git branch --show-current)
  if [ $BRANCH = "master" -o $BRANCH = "main" -o $BRANCH = "staging" -o $BRANCH = "production" ]
    echo "You're on $BRANCH!"
    return 1
  else if [ $(git config --get branch.$BRANCH.merge) ]
    echo "Branch $BRANCH already exists upstream"
    return 1
  else
    git push --set-upstream origin $BRANCH
  end
end
