// Enable pusher logging - don't include this in production
Pusher.log = function(message) {
  if (window.console && window.console.log) window.console.log(message);
};

// Flash fallback logging - don't include this in production
WEB_SOCKET_DEBUG = true;

var pusher = new Pusher('c65375e6d64ae2e5ba40');
var channel = pusher.subscribe('conversion_load_time_range_channel');
channel.bind('conversion_range_load_time_event', function(response) {
  var data = response["message"];

  categoriesText = [];
  for (var j = data.categories.length - 1; j >= 0; j--) {
    categoriesText = data.categories[j] + ' - ' + (data.categories[j] + 0.5);
  };

  chart.xAxis[0].setCategories(categoriesText, false);
  chart.series[0].setData(data.total, false);
  chart.series[1].setData(data.converted, false);
  chart.redraw(true);
});

function decrexp(x, a) {
  return Math.exp(-a * x);
};

function skewed(x, mean, sigma, alpha) {
  var y = (x - mean) / Math.sqrt(2 * sigma * sigma);
  var z = alpha * y;
  var normal = 1 / Math.sqrt(2 * Math.PI) / sigma * Math.exp(-y * y);
  var t = 1 / (1 + 0.3275911 * Math.abs(z));
  var a1 = 0.254829592;
  var a2 = -0.284496736;
  var a3 = 1.421413741;
  var a4 = -1.453152027;
  var a5 = 1.061405429;
  var erf = 1 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Math.exp(-z * z);
  var sign = 1;
  if (z < 0) {
    sign = -1;
  }
  var phi = (1 / 2) * (1 + sign * erf);
  return 2 * normal * phi
}
var i, sample = [],
  exp = [],
  rand;
var categories = [0, 0.5, 1, 1.5, 2, 2.5],
  sample = [0, 0, 0, 0, 0, 0];
for (i = 2000; i >= 0; i--) {
  rand = Math.random() * 5;
  var randFloor = Math.floor(rand * 2) / 2;
  var index = categories.indexOf(randFloor);
  if (index != -1) {
    sample[index] += Math.ceil(skewed(rand, 0.15, 1, 10) * 10) / 10;
  }
};

for (var j = 0; j < sample.length; j++) {
  exp[j] = decrexp(categories[j], 1);
};
var chart;
$(document).ready(function() {
  chart = new Highcharts.Chart({
    chart: {
      renderTo: 'chart',
      zoomType: 'xy'
    },
    title: {
      text: 'Actalyze'
    },
    credits: {
      enabled: false
    },
    yAxis: [{ // Primary yAxis
      labels: {
        style: {
          color: '#da953b'
        },
        formatter: function() {
          return this.value + '%';
        }
      },
      title: {
        text: 'Conversion',
        style: {
          color: '#da953b'
        }
      }
    }, {
      title: {
        text: 'Users',
        style: {
          color: '#5a7590'
        }
      },
      labels: {
        style: {
          color: '#5a7590'
        }
      },
      opposite: true
    }],
    xAxis: {
      categories: ["0 - 0.5", "0.5 - 1.0", "1.0 - 1.5", "1.5 - 2.0", "2.0 - 2.5", "2.5 - 3.0"],
      tickmarkPlacement: 'between'
    },
    plotOptions: {
      series: {
        animation: false
      }
    },
    tooltip: {
      formatter: function() {
        return '' + this.x + ': ' + this.y;
      }
    },
    series: [{
      name: 'Users',
      color: '#5a7590',
      type: 'column',
      data: [],
      yAxis: 1
    }, {
      name: 'Conversion',
      color: '#da953b',
      type: 'spline',
      data: []
    }]
  });
});
