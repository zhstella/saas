import { Controller } from "@hotwired/stimulus"

// 连接到 HTML 中的 data-controller="post-show"
export default class extends Controller {

  // 1. 定义这个 controller 需要操作的 "目标" (target)
  //    我们将把那个隐藏的 div 命名为 "commentForm"
  static targets = [ "commentForm" ]

  // 2. 这是我们将从 "Comments" 按钮调用的函数
  toggleCommentForm() {

    // 3. 切换那个隐藏 div (commentFormTarget) 上的 'visible' class
    this.commentFormTarget.classList.toggle('visible');
  }
}