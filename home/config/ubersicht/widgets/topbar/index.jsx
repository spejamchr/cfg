import {styled} from 'uebersicht';

export const refreshFrequency = 1000;

export const className = {
  top: 0,
  left: 0,
  width: '100%',
  height: '20px',
  backgroundColor: '#202020',
  color: '#a8a8a8',
  fontFamily: 'FiraCode Nerd Font',
  fontSize: '11px',
  whitespace: 'nowrap',
};

const sidePadding = 5; // px

const Container = styled.div({
  height: '100%',
  width: `calc(100% - ${sidePadding * 2}px)`,
  display: 'flex',
  justifyContent: 'space-between',
  alignItems: 'center',
  whiteSpace: 'nowrap',
  paddingLeft: `${sidePadding}px`,
  paddingRight: `${sidePadding}px`,
});

const Item = ({text, hide}) => <span>{hide ? '' : `( ${text} )`}</span>;

export const render = ({error, output}) => {
  if (error !== undefined) {
    console.error('[topbar]: ', error);
    return '';
  }

  if (output === '') {
    // First render, before the command has been run
    return '';
  }

  let parsed;
  try {
    parsed = JSON.parse(output);
  } catch (err) {
    console.error('[topbar]: ', err);
    console.dir(output);
    return 'Error Parsing JSON';
  }

  const length = 80;
  const song =
    parsed.song.length > length
      ? parsed.song.substring(0, length - 3) + '...'
      : parsed.song;

  const spacesString = `|${parsed.spaces
    .map(s => (s.focused === 1 ? `> ${s.index} <` : `| ${s.index} |`))
    .join('')}|`;

  const battery = `${parsed.plugged ? '' : ' '} ${parsed.battery}`;
  const date = `${''} ${parsed.date}`;
  const time = `${''} ${parsed.time}`;
  const bluetooth = parsed.bluetoothPower
    ? parsed.bluetoothConnected
      ? ' Paired'
      : ' On'
    : ' Off';

  return (
    <Container>
      <Item text={spacesString} hide={parsed.spaces.length === 0} />
      <Item text={song || 'Starting...'} hide={!parsed.pianobar} />
      <span>
        <Item text={bluetooth} />
        <Item text={battery} />
        <Item text={date} />
        <Item text={time} />
      </span>
    </Container>
  );
};

export const command = `
DATE=$(date "+%a %b %d")
TIME=$(date "+%H:%M:%S")
PIANOBAR=$([[ $(pgrep pianobar) ]] && printf 'true' || printf 'false')
SONG=$(cat ~/.config/pianobar/out | grep ' by ' | grep ' on ' | tail -n 1 | sed -e 's/^.*|> //')
SONG=\${SONG//'"'/'\\"'}
PLUGGED=$([[ $(pmset -g ps | head -1) =~ 'AC' ]] && printf 'true' || printf 'false')
BATTERY=$(pmset -g batt | egrep '(\\d+)\%' -o)
BLUETOOTH_POWER=$([[ $(blueutil --power) = 1 ]] && printf 'true' || printf 'false')
BLUETOOTH_CONNECTED=$([[ $(blueutil --paired | grep ', connected') ]] && printf 'true' || printf 'false')
SPACES=$(yabai -m query --spaces 2>/dev/null || echo [])

echo $(cat <<-EOF
{
	"date": "$DATE",
	"time": "$TIME",
    "pianobar": $PIANOBAR,
	"song": "$SONG",
    "plugged": $PLUGGED,
    "battery": "$BATTERY",
    "bluetoothPower":  $BLUETOOTH_POWER,
    "bluetoothConnected":  $BLUETOOTH_CONNECTED,
    "spaces": $SPACES
}
EOF
);
`;
