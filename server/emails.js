const emailjs = require('emailjs');
const scssToJson = require('scss-to-json');

const colorsFilepath = `${__dirname}/../frontend/stylesheets/colors.scss`;
const scssVars = scssToJson(colorsFilepath);
const email_translations = require('./email_translations');

module.exports = function init(params) {
  const { staticDir, smtp, mailFrom, serviceDomain, util, enableEmailGlobally } = params;

  const logo = {
    path: `${__dirname}/../frontend/assets/email_logo.png`,
    type: 'image/png',
    headers: { 'Content-ID': '<logo.png>' },
    name: 'logo.png',
  };

  function sendNotificationForAnswer(dbUser, ad) {
    const t = email_translations.sendNotificationForAnswer;
    const attachment = [
      { data: answerNotificationHtml(ad),
        alternative: true,
        related: [
          logo,
        ],
      },
    ];
    const { email_address, emails_for_answers } = util.formatSettings(dbUser.settings);
    sendEmail(email_address, emails_for_answers, t.text, t.subject, attachment);
  }

  function sendNotificationForContact(receiver, contactUser, introductionText) {
    const t = email_translations.sendNotificationForContact;
    const attachment = [
      { data: contactNotificationHtml(contactUser, introductionText),
        alternative: true,
        related: [
          logo,
          imageAttachment(contactUser.data.cropped_picture, '<picture>'),
        ],
      },
    ];
    const { email_address, emails_for_businesscards } = util.formatSettings(receiver.settings);
    sendEmail(email_address, emails_for_businesscards, t.text, t.subject, attachment);
  }

  function isUserPic(userPic) {
    return userPic && userPic.length > 0;
  }

  function imageAttachment(userPic, cid) {
    const pic = isUserPic(userPic) ? `images/${userPic}` : 'user.png';
    const imageType = pic.endsWith('.jpg') ? 'image/jpg' : 'image/png';

    return {
      path: `${staticDir}/${pic}`,
      type: imageType,
      headers: { 'Content-ID': cid },
      name: pic,
    };
  }

  function userPicStyle(userPic) {
    const width = isUserPic(userPic) ? '100%' : '50%';
    const marginTop = isUserPic(userPic) ? '' : 'margin-top: 25%;';
    return `width: ${width}; ${marginTop}`;
  }

  function sendNotificationForAds(user, ads) {
    const t = email_translations.sendNotificationForAds;
    function makeImage(ad, index) {
      return imageAttachment(ad.created_by.cropped_picture, `<picture${index}>`);
    }
    const adImages = ads.map(makeImage);
    const attachment = [
      { data: adNotificationHtml(ads),
        alternative: true,
        related: [logo].concat(adImages),
      },
    ];
    const { email_address, emails_for_new_ads } = util.formatSettings(user.settings);
    sendEmail(email_address, emails_for_new_ads, t.text, t.subject, attachment);
  }

  function sendRegistrationEmail(email_address, token) {
    const t = email_translations.sendRegistrationEmail;
    const content = `${t.text}\r\rhttps://${serviceDomain}/initpassword?token=${token}\r\r${t.signature}`;
    sendEmail(email_address, true, content, t.subject);
  }

  function sendRenewPasswordEmail(email_address, token) {
    const t = email_translations.sendRenewPasswordEmail;
    const content = `${t.text}\r\rhttps://${serviceDomain}/initpassword?token=${token}\r\r${t.signature}`;
    sendEmail(email_address, true, content, t.subject);
  }

  function sendEmail(email_address, allow_sending, text, subject, attachment) {
    if (!enableEmailGlobally) { return; }

    if (!(allow_sending && email_address && email_address.includes('@'))) { return; }

    const server = emailjs.server.connect(smtp);
    server.send({
      from: mailFrom,
      to: email_address,
      text: text,
      subject: subject,
      attachment: attachment,
    }, err => {
      if (err) {
        console.log(err);
      }
    });
  }


  function answerNotificationHtml(ad) {
    const t = email_translations.answerNotificationHtml;
    return (
      `
<html>
  <head></head>
  <body style="text-align: center; width: 600px; font-family: Arial, sans-serif; margin-left: auto; margin-right: auto;">
    <img style="width: 45px;" src="cid:logo.png" alt="logo" />
    <h1 style="margin-bottom: 50px; color: ${scssVars.$primary}">${t.h1}</h1>
    <p>${t.p1}</p>
    <p style="margin-top: 80px;">
      <a style="font-weight: bold; text-transform: uppercase; background-color: ${scssVars.$primary}; padding-left: 45px; padding-right: 45px; padding-top: 25px; padding-bottom: 25px; color: ${scssVars.$white}; text-decoration: none;" href="https://${serviceDomain}/ilmoitukset/${ad.id}">${t.a1}</a>
    </p>
    <h4 style="font-weight: bold; text-transform: uppercase; margin-top: 100px;">${t.h4}</h4>
    <div style="width: 80%; background-color: ${scssVars['$lighter-grey']}; border-color: ${scssVars['$medium-grey']}; border-style: solid; border-width: 1px; padding: 30px; margin-left: auto; margin-right: auto;">
      <h2 style="color: ${scssVars.$primary};">${ad.data.heading}</h2>
      <p>${ad.data.content}</p>
    </div>
    <p style="margin-top: 50px;">${t.p2} <a href="https://${serviceDomain}/asetukset" style="text-decoration: none; color: inherit; font-weight: bold;">${t.a2}</a>.</p>
  </body>
</html>
`
    );
  }

  function contactNotificationHtml(user, message) {
    const t = email_translations.contactNotificationHtml;
    return (
      `
<html>
  <head></head>
  <body style="text-align: center; width: 600px; font-family: Arial, sans-serif; margin-left: auto; margin-right: auto;">
    <img style="width: 45px;" src="cid:logo.png" alt="logo" />
    <h1 style="margin-bottom: 50px; color: ${scssVars.$primary}">${t.h1}</h1>
    <p>${t.p1}</p>
    <p>${t.p2}</p>
    <p style="margin-top: 80px;">
      <a style="font-weight: bold; text-transform: uppercase; background-color: ${scssVars.$primary}; padding-left: 45px; padding-right: 45px; padding-top: 25px; padding-bottom: 25px; color: ${scssVars.$white}; text-decoration: none;" href="https://${serviceDomain}/tradenomit/${user.id}">${t.a1}</a>
    </p>
    <p style="margin-top: 75px;margin-bottom: 50px;font-weight: bold;">“${message}”</p>
    <div style="padding: 30px; background-color: ${scssVars['$lighter-grey']}; text-align: left;">
      <span style="width: 80px; height: 80px; border-radius: 40px; display: inline-block; overflow: hidden; background-color: ${scssVars.$primary}; float: left; margin-bottom: 25px; margin-right: 10px;">
        <img src="cid:picture" style="${userPicStyle(user.data.cropped_picture)}">
        </img>
      </span>
      <span style="float: left;">
        <h3 style="margin-bottom: 5px;">${user.data.business_card.name}</h2>
        <h5 style="color: ${scssVars.$primary}; margin-top: 0;">${user.data.business_card.title}</h3>
      </span>
      <div style="clear: left;">
        ${makeBusinessCardLine(t.detailTitle1, user.data.business_card.location)}
        ${makeBusinessCardLine(t.detailTitle2, user.data.business_card.phone)}
        ${makeBusinessCardLine(t.detailTitle3, user.data.business_card.email)}
      </div>
    </div>
    <p style="margin-top: 50px;">${t.p3} <a href="https://${serviceDomain}/asetukset" style="text-decoration: none; color: inherit; font-weight: bold;">${t.a2}</a>.</p>
  </body>
</html>
`
    );
  }

  function makeBusinessCardLine(detailTitle, detailValue) {
    if (detailValue && detailValue.length > 0) {
      return `
    <p style="margin-top: 10px; margin-bottom: 10px;">
      <span style="font-weight: bold; margin-right: 5px;">${detailTitle}:</span>
      <span style="color: ${scssVars.$primary};">${detailValue}</span>
    </p>
    <hr style="background-color: ${scssVars['$medium-grey']}; height: 1px; border: 0;"></hr>`;
    }
    return '';
  }

  function singleAdHtml(ad, index) {
    const t = email_translations.singleAdHtml;
    const categories = [ad.domain, ad.position, ad.location].filter(x => x);
    const categoriesText = categories.length > 0 ? categories.join(', ') : `${t.categoriesText}`;
    return (
      `
<p style="margin-top: 45px; margin-bottom: 45px; font-weight: bold;">${categoriesText}</p>
<div style="padding: 30px; background-color: ${scssVars['$lighter-grey']}; text-align: center;">
  <span style="width: 80px; height: 80px; border-radius: 40px; display: inline-block; overflow: hidden; background-color: ${scssVars.$primary};">
    <img src="cid:picture${index}" style="${userPicStyle(ad.created_by.cropped_picture)}">
    </img>
  </span>
  <h3 style="margin-bottom: 5px;">${ad.created_by.name}</h2>
  <h5 style="color: ${scssVars.$primary}; margin-top: 0;">${ad.created_by.title}</h3>
  <h2 style="color: ${scssVars.$primary}; margin-top: 30px;">${ad.heading}</h2>
  <p>${ad.content}</p>
  <p style="margin-top: 50px; margin-bottom: 70px;">
    <a style="font-weight: bold; text-transform: uppercase; background-color: ${scssVars.$primary}; padding-left: 45px; padding-right: 45px; padding-top: 25px; padding-bottom: 25px; color: ${scssVars.$white}; text-decoration: none;" href="https://${serviceDomain}/ilmoitukset/${ad.id}">${t.a}</a>
  </p>
</div>
`
    );
  }

  function adNotificationHtml(ads) {
    const t = email_translations.adNotificationHtml;
    return (
      `
<html>
  <head></head>
  <body style="text-align: center; width: 600px; font-family: Arial, sans-serif; margin-left: auto; margin-right: auto;">
    <img style="width: 45px;" src="cid:logo.png" alt="logo" />
    <h1 style="margin-bottom: 50px; color: ${scssVars.$primary}; text-transform: uppercase; font-weight: bold;">${t.h1}</h1>
    <p style="margin-bottom: 25px;">${t.p1}</p>
    ${ads.map(singleAdHtml).join('')}
    <p style="margin-top: 50px;">${t.p2} <a href="https://${serviceDomain}/asetukset" style="text-decoration: none; color: inherit; font-weight: bold;">${t.a}</a>.</p>
  </body>
</html>
`
    );
  }


  return {
    sendNotificationForAnswer,
    sendNotificationForContact,
    sendNotificationForAds,
    sendRegistrationEmail,
    sendRenewPasswordEmail,
  };
};
