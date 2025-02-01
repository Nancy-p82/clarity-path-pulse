;; PathPulse Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-goal (err u103))

;; Data Variables
(define-map goals
  { goal-id: uint }
  {
    owner: principal,
    title: (string-utf8 100),
    description: (string-utf8 500),
    deadline: uint,
    completed: bool,
    private: bool
  }
)

(define-map milestones
  { goal-id: uint, milestone-id: uint }
  {
    title: (string-utf8 100),
    completed: bool,
    completion-date: (optional uint)
  }
)

(define-data-var goal-counter uint u0)

;; Public Functions
(define-public (create-goal (title (string-utf8 100)) (description (string-utf8 500)) (deadline uint) (is-private bool))
  (let
    ((new-goal-id (+ (var-get goal-counter) u1)))
    (map-set goals
      { goal-id: new-goal-id }
      {
        owner: tx-sender,
        title: title,
        description: description,
        deadline: deadline,
        completed: false,
        private: is-private
      }
    )
    (var-set goal-counter new-goal-id)
    (ok new-goal-id)
  )
)

(define-public (add-milestone (goal-id uint) (title (string-utf8 100)))
  (let
    ((goal (unwrap! (get-goal goal-id) (err err-not-found))))
    (asserts! (is-eq (get owner goal) tx-sender) (err err-unauthorized))
    (ok (map-set milestones
      { goal-id: goal-id, milestone-id: u1 }
      {
        title: title,
        completed: false,
        completion-date: none
      }
    ))
  )
)

;; Read Only Functions
(define-read-only (get-goal (goal-id uint))
  (map-get? goals { goal-id: goal-id })
)

(define-read-only (get-milestone (goal-id uint) (milestone-id uint))
  (map-get? milestones { goal-id: goal-id, milestone-id: milestone-id })
)
