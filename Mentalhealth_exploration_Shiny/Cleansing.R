##Cleansing....
raw <- read.csv("./data/raw_data_2.csv",stringsAsFactors = FALSE)
rem_prev <- raw[,!grepl("previous", colnames(raw))]
write.table(data.frame(new_names = paste0("C",1:length(colnames(rem_prev))),old_names = sort(colnames(rem_prev))),
            file = "Codebook.csv",sep = ",",col.names = NA)

# View(raw)
colnames(rem_prev)[colnames(rem_prev) == "Are.you.self.employed."] <- "Self_employed"
colnames(rem_prev)[colnames(rem_prev) == "How.many.employees.does.your.company.or.organization.have."] <- "Org_size"
colnames(rem_prev)[colnames(rem_prev) == "Is.your.employer.primarily.a.tech.company.organization."] <- "Is_tech"
colnames(rem_prev)[colnames(rem_prev) == "Does.your.employer.provide.mental.health.benefits.as.part.of.healthcare.coverage."] <- "Benefits"
colnames(rem_prev)[colnames(rem_prev) == "Is.your.anonymity.protected.if.you.choose.to.take.advantage.of.mental.health.or.substance.abuse.treatment.resources.provided.by.your.employer."] <- "Anonymity"
colnames(rem_prev)[colnames(rem_prev) == "If.a.mental.health.issue.prompted.you.to.request.a.medical.leave.from.work..asking.for.that.leave.would.be."] <- "Absence"
colnames(rem_prev)[colnames(rem_prev) == "Would.you.feel.comfortable.discussing.a.mental.health.disorder.with.your.coworkers."] <- "Coworkers"
colnames(rem_prev)[colnames(rem_prev) == "Do.you.feel.that.your.employer.takes.mental.health.as.seriously.as.physical.health."] <- "Ment_phy"
colnames(rem_prev)[colnames(rem_prev) == "What.is.your.age."] <- "Age"
colnames(rem_prev)[colnames(rem_prev) == "What.is.your.gender."] <- "Gender"
colnames(rem_prev)[colnames(rem_prev) == "What.US.state.or.territory.do.you.live.in."] <- "US_state"
colnames(rem_prev)[colnames(rem_prev) == "What.country.do.you.work.in."] <- "Country"
colnames(rem_prev)[colnames(rem_prev) == "What.US.state.or.territory.do.you.work.in."] <- "US_state_work"
colnames(rem_prev)[colnames(rem_prev) == "Have.you.been.diagnosed.with.a.mental.health.condition.by.a.medical.professional."] <- "Mental_ill"

mh_sub <- rem_prev

#Replace NA in Is your company tech with 1
mh_sub$Is_tech[is.na(mh_sub$Is_tech)] <- "Yes"

# View(rem_prev)

mh_sub <- rem_prev %>% select(c(Self_employed,
                                Org_size,
                                Mental_ill,
                                Is_tech,
                                Benefits,
                                Anonymity,
                                Absence,
                                Coworkers,
                                Ment_phy,
                                Age,
                                Gender,
                                US_state,
                                Country,
                                US_state_work))

# View(mh_sub)

# convert 0 and 1 to Yes and no for Tech and Self employed columns
mh_sub$Self_employed <- ifelse(mh_sub$Self_employed == 1,"Yes","No")
mh_sub$Is_tech <- ifelse(mh_sub$Is_tech == 1,"Yes","No")

mh_sub$Gender[mh_sub$Gender %in% c('male', 'Male ', 'M', 'm', 'man', 'Cis male',
                     'Male.', 'Male (cis)', 'Man', 'Sex is male',
                     'cis male', 'Malr', 'Dude', "I'm a man why didn't you make this a drop down question. You should of asked sex? And I would of answered yes please. Seriously how much text can this take? ",
                     'mail', 'M|', 'male ', 'Cis Male', 'Male (trans, FtM)',
                     'cisdude', 'cis man', 'MALE',"N/A","")] <- "Male"

mh_sub$Gender[mh_sub$Gender %in% c('female', 'I identify as female.', 'female ',
                                   'Female assigned at birth ', 'F', 'Woman', 'fm', 'f',
                                   'Cis female', 'Transitioned, M2F', 'Female or Multi-Gender Femme',
                                   'Female ', 'woman', 'female/woman', 'Cisgender Female',
                                   'mtf', 'fem', 'Female (props for making this a freeform field, though)',
                                   ' Female', 'Cis-woman', 'AFAB', 'Transgender woman',
                                   'Cis female ')] <- "Female"

mh_sub$Gender[mh_sub$Gender %in% c('Bigender', 'non-binary,', 'Genderfluid (born female)',
                                   'Other/Transfeminine', 'Androgynous', 'male 9:1 female, roughly',
                                   'nb masculine', 'genderqueer', 'Human', 'Genderfluid',
                                   'Enby', 'genderqueer woman', 'Queer', 'Agender', 'Fluid',
                                   'Genderflux demi-girl', 'female-bodied; no feelings about gender',
                                    'Male/genderqueer', 'Nonbinary', 'Other', 'none of your business',
                                   'Unicorn', 'human', 'Genderqueer','non-binary')] <- "Others"

