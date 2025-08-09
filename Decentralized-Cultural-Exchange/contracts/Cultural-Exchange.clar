;; Decentralized Cultural Exchange Contract
;; A platform for cross-cultural learning with immersive experiences

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_PARAMS (err u400))
(define-constant ERR_INSUFFICIENT_FUNDS (err u402))
(define-constant ERR_ALREADY_EXISTS (err u409))
(define-constant ERR_EXPERIENCE_ENDED (err u410))
(define-constant ERR_NOT_PARTICIPANT (err u411))
(define-constant ERR_ALREADY_REVIEWED (err u412))

;; Data Variables
(define-data-var platform-fee uint u50) ;; 5% platform fee (in basis points)
(define-data-var next-experience-id uint u1)
(define-data-var total-experiences uint u0)
(define-data-var total-participants uint u0)

;; Data Maps
(define-map cultural-experiences 
  { experience-id: uint }
  {
    host: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    culture: (string-ascii 50),
    location: (string-ascii 100),
    price: uint,
    max-participants: uint,
    current-participants: uint,
    start-time: uint,
    end-time: uint,
    is-active: bool,
    total-earned: uint
  }
)

(define-map experience-participants
  { experience-id: uint, participant: principal }
  {
    joined-at: uint,
    payment-amount: uint,
    has-attended: bool,
    review-given: bool
  }
)

(define-map host-profiles
  { host: principal }
  {
    name: (string-ascii 50),
    bio: (string-ascii 300),
    cultural-background: (string-ascii 100),
    rating: uint,
    total-reviews: uint,
    experiences-hosted: uint,
    is-verified: bool
  }
)

(define-map participant-profiles
  { participant: principal }
  {
    name: (string-ascii 50),
    interests: (string-ascii 200),
    experiences-joined: uint,
    cultural-badges: (list 10 (string-ascii 30))
  }
)

(define-map experience-reviews
  { experience-id: uint, reviewer: principal }
  {
    rating: uint,
    comment: (string-ascii 300),
    review-time: uint
  }
)

(define-map cultural-badges
  { badge-name: (string-ascii 30) }
  {
    description: (string-ascii 150),
    requirements: (string-ascii 200),
    reward-points: uint
  }
)

;; Read-only functions
(define-read-only (get-experience (experience-id uint))
  (map-get? cultural-experiences { experience-id: experience-id })
)

(define-read-only (get-host-profile (host principal))
  (map-get? host-profiles { host: host })
)

(define-read-only (get-participant-profile (participant principal))
  (map-get? participant-profiles { participant: participant })
)

(define-read-only (get-participation-details (experience-id uint) (participant principal))
  (map-get? experience-participants { experience-id: experience-id, participant: participant })
)

(define-read-only (get-experience-review (experience-id uint) (reviewer principal))
  (map-get? experience-reviews { experience-id: experience-id, reviewer: reviewer })
)

(define-read-only (get-platform-stats)
  {
    total-experiences: (var-get total-experiences),
    total-participants: (var-get total-participants),
    platform-fee: (var-get platform-fee)
  }
)

(define-read-only (is-experience-participant (experience-id uint) (participant principal))
  (is-some (map-get? experience-participants { experience-id: experience-id, participant: participant }))
)

;; Public functions
(define-public (create-host-profile (name (string-ascii 50)) (bio (string-ascii 300)) (cultural-background (string-ascii 100)))
  (begin
    (asserts! (is-none (map-get? host-profiles { host: tx-sender })) ERR_ALREADY_EXISTS)
    (map-set host-profiles
      { host: tx-sender }
      {
        name: name,
        bio: bio,
        cultural-background: cultural-background,
        rating: u0,
        total-reviews: u0,
        experiences-hosted: u0,
        is-verified: false
      }
    )
    (ok true)
  )
)

(define-public (create-participant-profile (name (string-ascii 50)) (interests (string-ascii 200)))
  (begin
    (asserts! (is-none (map-get? participant-profiles { participant: tx-sender })) ERR_ALREADY_EXISTS)
    (map-set participant-profiles
      { participant: tx-sender }
      {
        name: name,
        interests: interests,
        experiences-joined: u0,
        cultural-badges: (list)
      }
    )
    (ok true)
  )
)

(define-public (create-experience 
  (title (string-ascii 100))
  (description (string-ascii 500))
  (culture (string-ascii 50))
  (location (string-ascii 100))
  (price uint)
  (max-participants uint)
  (start-time uint)
  (end-time uint)
)
  (let
    (
      (experience-id (var-get next-experience-id))
      (host-profile (unwrap! (map-get? host-profiles { host: tx-sender }) ERR_UNAUTHORIZED))
    )
    (asserts! (> max-participants u0) ERR_INVALID_PARAMS)
    (asserts! (> end-time start-time) ERR_INVALID_PARAMS)
    (asserts! (> price u0) ERR_INVALID_PARAMS)
    
    (map-set cultural-experiences
      { experience-id: experience-id }
      {
        host: tx-sender,
        title: title,
        description: description,
        culture: culture,
        location: location,
        price: price,
        max-participants: max-participants,
        current-participants: u0,
        start-time: start-time,
        end-time: end-time,
        is-active: true,
        total-earned: u0
      }
    )
    
    ;; Update host profile
    (map-set host-profiles
      { host: tx-sender }
      (merge host-profile { experiences-hosted: (+ (get experiences-hosted host-profile) u1) })
    )
    
    ;; Update counters
    (var-set next-experience-id (+ experience-id u1))
    (var-set total-experiences (+ (var-get total-experiences) u1))
    
    (ok experience-id)
  )
)

(define-public (join-experience (experience-id uint))
  (let
    (
      (experience (unwrap! (map-get? cultural-experiences { experience-id: experience-id }) ERR_NOT_FOUND))
      (participant-profile (unwrap! (map-get? participant-profiles { participant: tx-sender }) ERR_UNAUTHORIZED))
      (price (get price experience))
      (platform-fee-amount (/ (* price (var-get platform-fee)) u10000))
      (host-payment (- price platform-fee-amount))
    )
    (asserts! (get is-active experience) ERR_EXPERIENCE_ENDED)
    (asserts! (< (get current-participants experience) (get max-participants experience)) ERR_INVALID_PARAMS)
    (asserts! (is-none (map-get? experience-participants { experience-id: experience-id, participant: tx-sender })) ERR_ALREADY_EXISTS)
    
    ;; Transfer payment
    (try! (stx-transfer? price tx-sender (as-contract tx-sender)))
    (try! (as-contract (stx-transfer? host-payment tx-sender (get host experience))))
    
    ;; Record participation
    (map-set experience-participants
      { experience-id: experience-id, participant: tx-sender }
      {
        joined-at: block-height,
        payment-amount: price,
        has-attended: false,
        review-given: false
      }
    )
    
    ;; Update experience
    (map-set cultural-experiences
      { experience-id: experience-id }
      (merge experience 
        { 
          current-participants: (+ (get current-participants experience) u1),
          total-earned: (+ (get total-earned experience) price)
        }
      )
    )
    
    ;; Update participant profile
    (map-set participant-profiles
      { participant: tx-sender }
      (merge participant-profile { experiences-joined: (+ (get experiences-joined participant-profile) u1) })
    )
    
    (var-set total-participants (+ (var-get total-participants) u1))
    (ok true)
  )
)

(define-public (mark-attendance (experience-id uint) (participant principal))
  (let
    (
      (experience (unwrap! (map-get? cultural-experiences { experience-id: experience-id }) ERR_NOT_FOUND))
      (participation (unwrap! (map-get? experience-participants { experience-id: experience-id, participant: participant }) ERR_NOT_PARTICIPANT))
    )
    (asserts! (is-eq tx-sender (get host experience)) ERR_UNAUTHORIZED)
    
    (map-set experience-participants
      { experience-id: experience-id, participant: participant }
      (merge participation { has-attended: true })
    )
    (ok true)
  )
)

(define-public (submit-review (experience-id uint) (rating uint) (comment (string-ascii 300)))
  (let
    (
      (experience (unwrap! (map-get? cultural-experiences { experience-id: experience-id }) ERR_NOT_FOUND))
      (participation (unwrap! (map-get? experience-participants { experience-id: experience-id, participant: tx-sender }) ERR_NOT_PARTICIPANT))
      (host-profile (unwrap! (map-get? host-profiles { host: (get host experience) }) ERR_NOT_FOUND))
    )
    (asserts! (get has-attended participation) ERR_UNAUTHORIZED)
    (asserts! (not (get review-given participation)) ERR_ALREADY_REVIEWED)
    (asserts! (and (>= rating u1) (<= rating u5)) ERR_INVALID_PARAMS)
    
    ;; Save review
    (map-set experience-reviews
      { experience-id: experience-id, reviewer: tx-sender }
      {
        rating: rating,
        comment: comment,
        review-time: block-height
      }
    )
    
    ;; Update participation
    (map-set experience-participants
      { experience-id: experience-id, participant: tx-sender }
      (merge participation { review-given: true })
    )
    
    ;; Update host rating
    (let
      (
        (total-reviews (+ (get total-reviews host-profile) u1))
        (current-total-rating (* (get rating host-profile) (get total-reviews host-profile)))
        (new-average-rating (/ (+ current-total-rating rating) total-reviews))
      )
      (map-set host-profiles
        { host: (get host experience) }
        (merge host-profile 
          {
            rating: new-average-rating,
            total-reviews: total-reviews
          }
        )
      )
    )
    (ok true)
  )
)

(define-public (award-cultural-badge (participant principal) (badge-name (string-ascii 30)))
  (let
    (
      (participant-profile (unwrap! (map-get? participant-profiles { participant: participant }) ERR_NOT_FOUND))
      (current-badges (get cultural-badges participant-profile))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    
    (map-set participant-profiles
      { participant: participant }
      (merge participant-profile 
        { cultural-badges: (unwrap! (as-max-len? (append current-badges badge-name) u10) ERR_INVALID_PARAMS) }
      )
    )
    (ok true)
  )
)

(define-public (update-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (<= new-fee u1000) ERR_INVALID_PARAMS) ;; Max 10%
    (var-set platform-fee new-fee)
    (ok true)
  )
)

;; Emergency function to deactivate experience
(define-public (deactivate-experience (experience-id uint))
  (let
    (
      (experience (unwrap! (map-get? cultural-experiences { experience-id: experience-id }) ERR_NOT_FOUND))
    )
    (asserts! (or (is-eq tx-sender (get host experience)) (is-eq tx-sender CONTRACT_OWNER)) ERR_UNAUTHORIZED)
    
    (map-set cultural-experiences
      { experience-id: experience-id }
      (merge experience { is-active: false })
    )
    (ok true)
  )
)