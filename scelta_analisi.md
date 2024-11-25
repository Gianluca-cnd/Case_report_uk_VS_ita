Ho più osservazioni dallo stesso soggetto, con un predittore (day_after_flight) che si ripete e un outcome continuo (midpoint_h_UTC):

Opzione 1: Modello Lineare Misto (Linear Mixed Model - LMM)
Motivazione: Poiché i dati sono raccolti ripetutamente dallo stesso individuo, si introduce una correlazione tra le misure. Un modello lineare misto è appropriato per gestire questo tipo di dipendenza all'interno dei dati. In questo modello: day_after_flight potrebbe essere considerato come un effetto fisso per verificare il suo impatto sul midpoint_h_UTC.
Il soggetto potrebbe essere considerato come effetto random per tenere conto della variabilità intra-soggetto.
La location potrebbe essere inclusa come covariata.

Opzione 2: ANOVA a Misure Ripetute
Motivazione: L'ANOVA a misure ripetute può essere utilizzata se vuoi esaminare gli effetti medi di day_after_flight sul midpoint_h_UTC. Tuttavia, ci sono alcune limitazioni: l'ANOVA a misure ripetute richiede che le osservazioni siano equidistanti e che i dati soddisfino l'assunzione di sfericità (che potrebbe non essere rispettata).
In questo caso specifico, con cambi di location e una variabile temporale che cresce in modo non sempre uniforme, potrebbe non essere il modello ideale.