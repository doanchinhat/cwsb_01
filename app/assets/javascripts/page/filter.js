$(document).ready(function(){
  $('#filter_slider').on('slide', function (){
    value_array = $('#filter_slider').val().split(',');
    $('#price_amount').val('$' + value_array[0] + ' - $' + value_array[1]);
    var min = value_array[0];
    var max = value_array[1];
    filterSystem(min, max);
    filterWindow(min, max);
  });
});

function filterSystem(minPrice, maxPrice) {
  $('#search-space-result div.search_space').hide().filter(function () {
    var price = parseInt($(this).data('price'), 10);
    return price >= minPrice && price <= maxPrice;
  }).show();
}

function filterWindow(minPrice, maxPrice) {
  $('#list_space_in_window div.space_in_window ').hide().filter(function () {
    var price = parseInt($(this).data('price'), 10);
    return price >= minPrice && price <= maxPrice;
  }).show();
}

$(document).ready(function(){
  $('#sort-space').on('change', function() {
    var list_space = document.getElementsByClassName('search_space_detail');
    var vals = [];
    sort_condition = $('#sort-space').val();
    if(sort_condition){
      vals = getSorted('.search_space_detail', 'data-price', sort_condition);
      list_space = vals;
      for(var i = 0, l = list_space.length; i < l; i++){
        $('#search-space-result').append(list_space[i]);
      }
    }
  });
});

function getSorted(selector, attrName, sort_condition) {
  return $($(selector).toArray().sort(function(element_before, element_after){
    var element_before_value = parseInt(element_before.getAttribute(attrName)),
      element_after_value = parseInt(element_after.getAttribute(attrName));
    if(sort_condition == 'price_high'){
      return element_after_value - element_before_value;}
    if(sort_condition == 'price_low'){
      return element_before_value - element_after_value;}
  }));
}
