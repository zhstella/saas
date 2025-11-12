import { Controller } from "@hotwired/stimulus"

// 连接到 HTML 中的 data-controller="post-show"
export default class extends Controller {

  // 1. 定义这个 controller 需要操作的 "目标" (target)
  //    我们将把那个隐藏的 div 命名为 "answerForm"
  static targets = [ "answerForm" ]

  // 2. 这是我们将从 "Answers" 按钮调用的函数
  toggleAnswerForm() {

    // 3. 切换那个隐藏 div (answerFormTarget) 上的 'visible' class
    this.answerFormTarget.classList.toggle('visible');
  }
}
