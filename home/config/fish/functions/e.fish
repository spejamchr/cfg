function e
  if [ (count $argv) = 0 ]
    $EDITOR .
  else if [ -d $argv[1] ]
    cd $argv[1]
    [ -f .ruby-version ] && chruby (cat .ruby-version)
    $EDITOR .
  else
    $EDITOR $argv[1]
  end
end
