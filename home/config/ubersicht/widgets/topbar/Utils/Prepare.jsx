// Parse the output

export default (name, fn) => ({ error, output }) => {
  if (error !== undefined) {
    console.error(`[${name}]: `, error);
    return "";
  }

  if (output === "") {
    // First render, before the command has been run
    return "";
  }

  let parsed;
  try {
    parsed = JSON.parse(output);
  } catch (err) {
    console.error("[topbar]: ", err);
    console.dir(output);
    return "Error Parsing JSON";
  }

  return fn(parsed);
};
