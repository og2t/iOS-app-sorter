document.body.addEventListener 'touchmove', (event) ->
  event.preventDefault()
  return

# window.onresize = ->
#   document.body.scrollLeft = '0px'
#   document.body.scrollTop = '0px'
#   return


class ShuffleGrid

  VENDORS = ['webkit', 'Moz']

  constructor: (@context, @cols, @rows, @colSize, @rowSize, @paddingX = 0, @paddingY = 0) ->
    @numItems = 0
    @initIndex()

    @items = [].slice.call @context.children
    @items.forEach (item, id) =>
      @addItem item
    return


  initIndex: () =>
    @itemVOs = []
    @index = new Array @rows

    i = 0
    while i < @rows
      @index[i++] = new Array @cols
    return


  addItem: (item) =>
    col = @numItems % @cols
    row = Math.floor @numItems / @cols

    position = @getPosition row, col

    id = @numItems
    @numItems++
    
    itemVO =
      row: row
      col: col
      item: item
      id: id

    item.style.width = "#{@colSize}px"
    item.style.height = "#{@rowSize}px"
    item.setAttribute 'id', id
    @positionItem item, position.x, position.y

    
    @index[row][col] = itemVO
    @itemVOs[id] = itemVO

    if hasClass item, 'placeholder' then return

    item.children[0].style.webkitAnimationDelay = Math.random() * 0.5 + 's'
    # item.children[0].style.animationDelay = Math.random() * 0.5 + 's'
    
    # item.addEventListener 'touchstart', @onTouchStart, false
    # item.addEventListener 'touchend', @onTouchEnd, false
    item.addEventListener 'mousedown', @onMousePress, false
    return item


  shuffleItems: () =>
    itemVO = @itemVOs[@currentItem.getAttribute 'id']

    cell = @getCell parseInt(@currentItem.getAttribute 'x'), parseInt(@currentItem.getAttribute 'y')

    col = cell.x
    row = cell.y

    return if col is itemVO.col and row is itemVO.row

    hMove = col - itemVO.col
    vMove = row - itemVO.row

    move = []

    if hMove < 0
      i = itemVO.col - 1
      while i >= itemVO.col + hMove
        if @index[itemVO.row][i]
          item = @index[itemVO.row][i]
          item.col++
          @index[item.row][item.col] = item
          move.push item
        i--
    else
      i = itemVO.col + 1
      while i <= itemVO.col + hMove
        if @index[itemVO.row][i]
          item = @index[itemVO.row][i]
          item.col--
          @index[item.row][item.col] = item
          move.push item
        i++

    if vMove < 0
      i = itemVO.row - 1
      while i >= itemVO.row + vMove
        if @index[i][itemVO.col + hMove]
          item = @index[i][itemVO.col + hMove]
          item.row++
          @index[item.row][item.col] = item
          move.push item
        i--
    else
      i = itemVO.row + 1
      while i <= itemVO.row + vMove
        if @index[i][itemVO.col + hMove]
          item = @index[i][itemVO.col + hMove]
          item.row--
          @index[item.row][item.col] = item
          move.push item
        i++
    
    i = 0
    while i < move.length
      @snapToGrid move[i++]

    itemVO.row = row
    itemVO.col = col
    @index[row][col] = itemVO
    return


  snapToGrid: (itemVO) =>
    position = @getPosition itemVO.row, itemVO.col
    @positionItem itemVO.item, position.x, position.y
    return


  positionItem: (item, x, y) =>
    for vendor in VENDORS
      item.style["#{vendor}Transform"] = "translateX(#{x}px) translateY(#{y}px)"
    return


  getPosition: (row, col) =>

    # Only for the iPhone demo
    if row > 4 then offsetY = 20 else offsetY = 0 

    position = 
      x: col * (@colSize + @paddingX)
      y: row * (@rowSize + @paddingY) + offsetY
    return position


  getCell: (x, y) =>
    cell = 
      x: Math.max(0, Math.min(@cols - 1, Math.round(x / (@colSize + @paddingX))))
      y: Math.max(0, Math.min(@rows - 1, Math.round(y / (@rowSize + @paddingY))))
    return cell


  # onTouchStart: (event) =>
  #   @currentItem = event.changedTouches[0].target
    
  #   contextOffset = @context.getBoundingClientRect()
  #   @originOffset = 
  #     x: event.changedTouches[0].clientX + contextOffset.left + 16
  #     y: event.changedTouches[0].clientY + contextOffset.top + 26

  #   @startDrag @currentItem
  #   # @onTouchMove event
  #   @context.addEventListener 'touchmove', @onTouchMove, false
  #   # item.addEventListener("touchcancel", touchCancel, false);
  #   return


  # onTouchMove: (event) =>
  #   x = event.changedTouches[0].clientX - @originOffset.x
  #   y = event.changedTouches[0].clientY - @originOffset.y 
  #   @currentItem.setAttribute 'x', x
  #   @currentItem.setAttribute 'y', y
  #   console.log x, y
  #   @positionItem @currentItem, x, y
  #   @shuffleItems()
  #   return


  # onTouchEnd: (event) =>
  #   return


  onMousePress: (event) =>
    @currentItem = event.currentTarget
 
    contextOffset = @context.getBoundingClientRect()
    @originOffset = 
      x: event.offsetX + contextOffset.left + 16
      y: event.offsetY + contextOffset.top + 26

    @startDrag @currentItem
    @onMouseMove event
    @context.addEventListener 'mouseup', @onMouseRelease, false
    @context.addEventListener 'mousemove', @onMouseMove, false
    @context.addEventListener 'mouseleave', @onMouseRelease, false
    return


  onMouseMove: (event) =>
    x = event.clientX - @originOffset.x
    y = event.clientY - @originOffset.y
    @currentItem.setAttribute 'x', x
    @currentItem.setAttribute 'y', y
    @positionItem @currentItem, x, y
    @shuffleItems()
    return
  

  onMouseRelease: (event) =>
    @currentItem.removeEventListener 'mouseout', @onMouseRelease
    @stopDrag @currentItem
    @context.removeEventListener 'mousemove', @onMouseMove
    @snapToGrid @itemVOs[@currentItem.getAttribute 'id']
    return


  numCells: () =>
   return @rows * @cols


  startDrag: (item) =>
    item.style.zIndex = 1000
    addClass item, 'dragging'
    addClass @context, 'shaking'
    return  


  stopDrag: (item) =>
    removeClass item, 'dragging'
    removeClass @context, 'shaking'
    @currentItem.addEventListener transitionEndEvent(), @onTransitionEnd
    return  


  onTransitionEnd: (event) =>
    @currentItem.style.zIndex = 'auto'
    @currentItem.removeEventListener transitionEndEvent(), @onTransitionEnd
    return


iconsList = document.querySelector '.icons-list ul'
grid = new ShuffleGrid iconsList, 4, 6, 60, 60, 16, 28