#!vanilla

# MathJax in a comment: $\Psi(t) = \int_0^\infty \theta_n(t) dt$ 

# Link in a comment: <a href="/">puzlet.com</a>

# This Ace editor
editor = $blab.editors.coffeeEditor.editor 

# Render code comments.
# Save to $blab.comments to handle Run button.
render = ->
    nodes = $ ".ace_comment"  # or container find
    $blab.comments = (new CodeNodeComment($(node), linkCb) for node in nodes)
    comment.render() for comment in $blab.comments
    
# Restore code comments to original source.
restore = -> comment.restore() for comment in $blab.comments
restore() if $blab.comments  # Restore if click Run button.

class CodeNodeComment

    constructor: (@node, @linkCallback) ->
    
    render: ->
        @originalText = @node.text()
        @replaceDiv()
        @mathJax()
        @processLinks()
    
    replaceDiv: ->
        pattern = String.fromCharCode(160)
        re = new RegExp(pattern, "g")
        comment = @originalText.replace(re, " ")
        @node.empty()
        content = $ "<div>", css: display: "inline-block"
        content.append comment
        @node.append content
    
    mathJax: ->
        return unless node = @node[0]
        Hub = MathJax.Hub
        Hub.Queue(["PreProcess", Hub, node])
        Hub.Queue(["Process", Hub, node])
    
    processLinks: ->
        links = @node.find "a"
        return unless links.length
        for link in links
            $(link).mousedown (evt) => @linkCallback $(evt.target)
    
    restore: ->
        return unless @originalText
        @node.empty()
        @node.text @originalText

# State variable and callback for link selection
linkSelected = false
linkCb = (target) -> linkSelected = target

# Comment link navigation
mouseUp = ->
    return unless linkSelected
    href = linkSelected.attr "href"
    target = linkSelected.attr "target"
    if target is "_self"
        $(document.body).animate {scrollTop: $(href).offset().top}, 1000
    else
        window.open href, target ? "_blank"
    linkSelected = false
    editor.blur()

$blab.onFocus = -> restore()
$blab.onBlur = -> render()

unless $blab.initialized
    
    onFocus = editor.onFocus
    editor.onFocus = ->
        $blab.onFocus()
        onFocus.call editor
        
    onBlur = editor.onBlur
    editor.onBlur = ->
        $blab.onBlur()
        onBlur.call editor
    $blab.initialized = true
    
    editor.on "mouseup", (aceEvent) -> mouseUp()

# Render code comments when MathJax ready.
render() if MathJax?.Hub
$(document).on "mathjaxPreConfig", ->
    window.MathJax.Hub.Register.StartupHook "MathMenu Ready", -> render()

#!end (coffee)

