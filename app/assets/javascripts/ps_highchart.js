// Enable pusher logging - don't include this in production
Pusher.log = function(message) {
  if (window.console && window.console.log) window.console.log(message);
};

// Flash fallback logging - don't include this in production
WEB_SOCKET_DEBUG = true;

var pusher = new Pusher('c65375e6d64ae2e5ba40');
var channel = pusher.subscribe('conversion_load_time_range_channel');
channel.bind('conversion_range_load_time_event', function(response) {
  var data = response["data"];
  console.log(JSON.stringify(data))
  chart.xAxis[0].setCategories(data.categories, false);
  chart.series[0].setData(data.total, false);
  chart.series[1].setData(data.converted, false);
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
      text: 'Actalyze'
    },
    credits: {
      enabled: false
    },
    yAxis: [{ // Primary yAxis
      labels: {
        style: {
          color: '#89A54E'
        },
        formatter: function() {
          return this.value +'%';
        }
      },
      title: {
        text: 'Conversion',
        style: {
          color: '#89A54E'
        }
      }
    }, {
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
      color: '#4572A7',
      type: 'column',
      data: [],
      yAxis: 1
    }, {
      name: 'Conversion',
      color: '#89A54E',
      type: 'spline',
      data: []
    }]
  });
});
