/* eslint-disable no-restricted-syntax */
const fs = require('fs');

// eslint-disable-next-line import/no-dynamic-require
const scssVars = require(`${__dirname}/../frontend/stylesheets/colors.json`);
const scssFile = `${__dirname}/../frontend/stylesheets/jsoncolors.scss`;

let scss = '';
for (const key of Object.keys(scssVars)) {
  scss += `${key}: ${scssVars[key]};\n`;
}
fs.writeFileSync(scssFile, scss);
