$(function() {
  var chartData;

  var benchmarksData = $(".js-benchmarks-data")

  if(benchmarksData.length == 0) {
    return;
  }

  chartData = JSON.parse(benchmarksData.text());

  if(chartData == null) {
    return;
  }

  var chartsContainer = $(".js-charts-container");

  for(var i=0; i < chartData.length; i++) {
    var margin = {top: 20, right: 20, bottom: 30, left: 40},
        width = 300 - margin.left - margin.right,
        height = 400 - margin.top - margin.bottom;

    var x = d3.scale.ordinal()
        .rangeRoundBands([0, width], .1);

    var formatValue = d3.format(".2s");

    var y = d3.scale.linear()
        .range([height, 0])

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .ticks(10, "2s");

    var node = $("<div></div>").addClass('chart')

    var svg = d3.select(node[0]).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      var data = chartData[i][1]

      //   var data = [
      // { label: "3.2.1", ips: 22328.71492},
      // { label: "4.0.0", ips: 20328.22782}]

    x.domain(data.map(function(d) { return d.label; }));
    y.domain([0, d3.max(data, function(d) { return d.ips; })]);

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("IPS");

    var barClass = function(d) {
      console.log(d)
      if(d) {
        return "bar_current"
      } else {
        return "bar"
      }
    };
    var labelFormatter = d3.format(".4f")
    svg.selectAll(".bar")
        .data(data)
      .enter().append("rect")
        .attr("class", function(d) { return barClass(d.current); })
        .attr("x", function(d) { return x(d.label) + 10; })
        .attr("width", x.rangeBand() - 20)
        .attr("y", function(d) { return y(d.ips); })
        .attr("height", function(d) { return height - y(d.ips); })
        .append("svg:title")
         .text(function(d) { return labelFormatter(d.ips); });

    var label = $("<div></div>").text(chartData[i][0])
    label.addClass("chart-label")
    node.append(label)

    chartsContainer.append(node)
  }
})
