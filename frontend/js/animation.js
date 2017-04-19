import { timer } from 'd3-timer';
import getStyleValues from './style-values';

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

      const { navbarHeight, pink, green, white } = getStyleValues();

      const offset = isSplashScreen ? 0 : navbarHeight
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

      function onResize() {
        const { navbarHeight } = getStyleValues();
        const offset = isSplashScreen ? 0 : navbarHeight

        canvas.width  = window.innerWidth;
        const widthRatio = width / canvas.width;
        width = canvas.width;

        canvas.height  = window.innerHeight - offset;
        const heightRatio = height / canvas.height;
        height = canvas.height;

        particles.forEach(particle => {
          particle.x /= widthRatio;
          particle.y /= heightRatio;
        })
      }

      // from MDN
      (function() {
        window.addEventListener("resize", resizeThrottler, false);

        var resizeTimeout;
        function resizeThrottler() {
          // ignore resize events as long as an actualResizeHandler execution is in the queue
          if ( !resizeTimeout ) {
            resizeTimeout = setTimeout(function() {
              resizeTimeout = null;
              onResize();

              // The actualResizeHandler will execute at a rate of 15fps
            }, 66);
          }
        }
      }());

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
