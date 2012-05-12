// Enable pusher logging - don't include this in production
Pusher.log = function(message) {
  if (window.console && window.console.log) window.console.log(message);
};

// Flash fallback logging - don't include this in production
WEB_SOCKET_DEBUG = true;

var pusher = new Pusher('c65375e6d64ae2e5ba40');
var channel = pusher.subscribe('conversion_load_time_range_channel');
channel.bind('range_load_time_event', function(data) {
  var data = data["message"];
  chart.series[0].setData(data[0], false);
  chart.series[1].setData(data[1], false);
  chart.redraw(true);
});

var chart;
$(document).ready(function() {
  chart = new Highcharts.Chart({
    chart: {
      renderTo: 'chart',
      zoomType: 'xy'
    },
    title: {
      text: 'Actalize'
    },
    credits: {
      enabled: false
    },
    yAxis: [{ // Primary yAxis
      labels: {
        style: {
          color: '#89A54E'
        }
      },
      title: {
        text: 'Conversion',
        style: {
          color: '#89A54E'
        }
      }
    }, { // Secondary yAxis
      title: {
        text: 'Users',
        style: {
          color: '#4572A7'
        }
      },
      labels: {
        style: {
          color: '#4572A7'
        }
      },
      opposite: true
    }],
    tooltip: {
      formatter: function() {
        return '' + this.x + ': ' + this.y;
      }
    },
    series: [{
      name: 'Conversion',
      color: '#4572A7',
      type: 'column',
      yAxis: 1,
      data: []

    }, {
      name: 'Users',
      color: '#89A54E',
      type: 'spline',
      data: []
    }]
  });
});
