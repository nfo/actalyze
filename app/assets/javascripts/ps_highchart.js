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
    xAxis: [{
      categories: ['< 1s', '1s - 2s', '2s - 3s', '3s - 4s', '> 5s']
    }],
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
      name: 'Rainfall',
      color: '#4572A7',
      type: 'column',
      yAxis: 1,
      data: [144.0, 129.2, 106.4, 71.5, 49.9]

    }, {
      name: 'Temperature',
      color: '#89A54E',
      type: 'spline',
      data: [18.2, 14.5, 9.5, 7.0, 6.9]
    }]
  });
});
