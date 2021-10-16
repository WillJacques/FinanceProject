window.searchStockTable = function() {
  // Declare variables
  var input, filter, table, tr, td, i, txtValue;
  input = document.getElementById("mystocksearch");
  filter = input.value.toUpperCase();
  table = document.getElementById("stocktable");
  tr = table.getElementsByClassName("row");

  // Loop through all table rows, and hide those who don't match the search query
  for (i = 0; i < tr.length; i++) {
    td = tr[i];
    if (td) {
      txtValue = td.textContent || td.innerText;
      console.log(txtValue);
      if (txtValue.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
      } else {
        tr[i].style.display = "none";
      }
    }
  }
}
