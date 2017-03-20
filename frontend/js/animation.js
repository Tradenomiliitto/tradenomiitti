import { timer } from 'd3-timer';

// particle animation used under GPL license from https://bl.ocks.org/mbostock/280d83080497c8c13152 and http://mustafasaifee.com/

export default function initAnimation(port) {
  port.subscribe(([ id, isSplashScreen ]) => {

    //wait until element is rendered
    let counter = 0;
    const timeoutId = setInterval(function () {
      counter += 1;

      const el = document.getElementById(id);

      if (el) {
        clearTimeout(timeoutId);
        init(el);
      } else if (counter > 10) {
        clearTimeout(timeoutId);
      }
    }, 20);

    function init(canvas) {
      var context = canvas.getContext("2d");

      const styleValueInPx = getStyleRuleValue('height', '#navbar-height-to-js');
      const offset = isSplashScreen ? 0 : Number(styleValueInPx.replace(/[^\d]+/, ''))

      const pink = getStyleRuleValue('color', '#pink-to-js');
      const green = getStyleRuleValue('color', '#green-to-js');
      const white = getStyleRuleValue('color', '#white-to-js');

      const color = isSplashScreen ? [ white, white ] : [pink, green];
      const stk = color;

      canvas.onclick = create;

      canvas.width  = window.innerWidth;
      canvas.height  = window.innerHeight - offset;
      var width = canvas.width,
          height = canvas.height,
          rad = 1.5,
          minDistance = 40,
          maxDistance = 150,
          minDistance2 = minDistance * minDistance,
          maxDistance2 = maxDistance * maxDistance;
      var tau = 2 * Math.PI,
          n = 20,
          particles = new Array(n);

      for (var i = 0; i < n; ++i) {
        var color_index = Math.floor(Math.random() * 2)
        var stk_index = Math.floor(Math.random() * 2)
        particles[i] = {
          x: Math.random() * width,
          y: Math.random() * height,
          vx: 0,
          vy: 0,
          radius: Math.ceil((Math.abs(Math.random() - .5)*10)+1),
          col: color[color_index],
          stroke: stk[stk_index]
        };
      }

      timer(function(elapsed) {
        context.save();
        context.clearRect(0, 0, width, height);

        for (let i = 0; i < n; ++i) {
          for (var j = i + 1; j < n; ++j) {
            var pi = particles[i],
                   pj = particles[j],
                   dx = pi.x - pj.x,
                   dy = pi.y - pj.y,
                   d2 = dx * dx + dy * dy;
            if (d2 < maxDistance2) {
              context.globalAlpha = d2 > minDistance2 ? ((maxDistance2 - d2) / (maxDistance2 - minDistance2))/2 : 1;
              context.beginPath();
              context.moveTo(pi.x, pi.y);
              context.lineTo(pj.x, pj.y);
              context.strokeStyle = pi.stroke;
              context.stroke();
            }
          }
        }

        for (let i = 0; i < n; ++i) {
          var p = particles[i];

          p.x += p.vx;
          if (p.x < -maxDistance)
            p.x += width + maxDistance * 2;
          else if (p.x > width + maxDistance)
            p.x -= width + maxDistance * 2;

          p.y += p.vy;
          if (p.y < -maxDistance)
            p.y += height + maxDistance * 2;
          else if (p.y > height + maxDistance)
            p.y -= height + maxDistance * 2;

          p.vx += 0.1 * (Math.random() - .5) - 0.01 * p.vx;
          p.vy += 0.1 * (Math.random() - .5) - 0.01 * p.vy;

          context.beginPath();

          context.globalAlpha = 1;

          context.arc(p.x, p.y, p.radius, 0, tau);

          context.fillStyle = p.col;

          context.fill();

          context.restore();
        }
      });

      function create(event){
        var x1 = event.clientX;
        var y1 = event.clientY - offset + window.pageYOffset;
        n = n + 1;
        var color_index = Math.floor(Math.random() * 5)
        var stk_index = Math.floor(Math.random() * 4)
        particles.push({
          x: x1,
          y: y1,
          vx: 0,
          vy: 0,
          radius: Math.ceil((Math.abs(Math.random() - .5)*10)+1),
          col: color[color_index],
          stroke: stk[stk_index]
        });
      }

    }
  })
}

function getStyleRuleValue(style, selector) {
  for (var i = 0; i < document.styleSheets.length; i++) {
    try {
      var mysheet = document.styleSheets[i];
      var myrules = mysheet.cssRules ? mysheet.cssRules : mysheet.rules;
      for (var j = 0; j < myrules.length; j++) {
        if (myrules[j].selectorText && myrules[j].selectorText.toLowerCase() === selector) {
          return myrules[j].style[style];
        }
      }
    } catch (e) {}
  }
}
